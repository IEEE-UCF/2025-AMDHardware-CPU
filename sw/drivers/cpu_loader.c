/**
 * CPU Program Loader for Red Pitaya RISC-V CPU
 * 
 * Handles loading of ELF files, binary files, and hex files
 * Compatible with Red Pitaya 125-14 hardware platform
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <elf.h>

#include "cpu_driver.h"
#include "cpu_regs.h"

// ELF file support
#ifdef __LP64__
typedef Elf64_Ehdr Elf_Ehdr;
typedef Elf64_Phdr Elf_Phdr;
typedef Elf64_Shdr Elf_Shdr;
typedef Elf64_Sym Elf_Sym;
#else
typedef Elf32_Ehdr Elf_Ehdr;
typedef Elf32_Phdr Elf_Phdr;
typedef Elf32_Shdr Elf_Shdr;
typedef Elf32_Sym Elf_Sym;
#endif

// File types
typedef enum {
    FILE_TYPE_UNKNOWN,
    FILE_TYPE_ELF,
    FILE_TYPE_BIN,
    FILE_TYPE_HEX,
    FILE_TYPE_SREC
} file_type_t;

// Program info structure
typedef struct {
    uint32_t entry_point;
    uint32_t load_address;
    size_t program_size;
    size_t data_size;
    uint32_t stack_pointer;
    char filename[256];
    file_type_t file_type;
} program_info_t;

// Internal functions
static file_type_t detect_file_type(const char *filename, const uint8_t *data, size_t size);
static int load_elf_file(const char *filename, program_info_t *info);
static int load_binary_file(const char *filename, uint32_t load_addr, program_info_t *info);
static int load_hex_file(const char *filename, program_info_t *info);
static int verify_elf_header(const Elf_Ehdr *ehdr);
static int parse_hex_line(const char *line, uint32_t *addr, uint8_t *data, size_t *len);
static void print_program_info(const program_info_t *info);

/**
 * Load program from file
 */
int cpu_load_program_file(const char *filename, uint32_t load_addr) {
    if (!filename) {
        printf("Error: Invalid filename\n");
        return CPU_ERROR_INVALID;
    }

    printf("Loading program: %s\n", filename);

    // Check if file exists
    if (access(filename, R_OK) != 0) {
        printf("Error: Cannot access file %s: %s\n", filename, strerror(errno));
        return CPU_ERROR_INVALID;
    }

    // Read file to detect type
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        printf("Error: Cannot open file %s: %s\n", filename, strerror(errno));
        return CPU_ERROR_INVALID;
    }

    // Get file size
    fseek(fp, 0, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    if (file_size <= 0 || file_size > 1024*1024) {  // Max 1MB
        printf("Error: Invalid file size: %ld bytes\n", file_size);
        fclose(fp);
        return CPU_ERROR_INVALID;
    }

    // Read first few bytes to detect file type
    uint8_t header[16];
    size_t header_read = fread(header, 1, sizeof(header), fp);
    fclose(fp);

    if (header_read < 4) {
        printf("Error: File too small to determine type\n");
        return CPU_ERROR_INVALID;
    }

    // Detect file type
    file_type_t file_type = detect_file_type(filename, header, header_read);
    
    program_info_t prog_info = {0};
    strcpy(prog_info.filename, filename);
    prog_info.file_type = file_type;
    
    int result = CPU_ERROR;
    
    switch (file_type) {
        case FILE_TYPE_ELF:
            printf("Detected ELF file format\n");
            result = load_elf_file(filename, &prog_info);
            break;
            
        case FILE_TYPE_BIN:
            printf("Detected binary file format\n");
            result = load_binary_file(filename, load_addr, &prog_info);
            break;
            
        case FILE_TYPE_HEX:
            printf("Detected Intel HEX file format\n");
            result = load_hex_file(filename, &prog_info);
            break;
            
        default:
            printf("Error: Unsupported file format\n");
            result = CPU_ERROR_INVALID;
            break;
    }

    if (result == CPU_SUCCESS) {
        print_program_info(&prog_info);
        
        // Set entry point
        if (prog_info.entry_point != 0) {
            cpu_set_pc(prog_info.entry_point);
            printf("Entry point set to 0x%08x\n", prog_info.entry_point);
        }
        
        printf("Program loaded successfully\n");
    }

    return result;
}

/**
 * Load ELF file
 */
static int load_elf_file(const char *filename, program_info_t *info) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        printf("Error: Cannot open ELF file %s\n", filename);
        return CPU_ERROR_INVALID;
    }

    // Read ELF header
    Elf_Ehdr ehdr;
    if (fread(&ehdr, sizeof(ehdr), 1, fp) != 1) {
        printf("Error: Cannot read ELF header\n");
        fclose(fp);
        return CPU_ERROR_INVALID;
    }

    // Verify ELF header
    if (verify_elf_header(&ehdr) != 0) {
        fclose(fp);
        return CPU_ERROR_INVALID;
    }

    info->entry_point = ehdr.e_entry;
    printf("ELF entry point: 0x%08x\n", info->entry_point);

    // Read program headers
    if (ehdr.e_phnum == 0) {
        printf("Warning: No program headers found\n");
        fclose(fp);
        return CPU_ERROR_INVALID;
    }

    fseek(fp, ehdr.e_phoff, SEEK_SET);
    
    for (int i = 0; i < ehdr.e_phnum; i++) {
        Elf_Phdr phdr;
        if (fread(&phdr, sizeof(phdr), 1, fp) != 1) {
            printf("Error: Cannot read program header %d\n", i);
            fclose(fp);
            return CPU_ERROR_INVALID;
        }

        // Only load PT_LOAD segments
        if (phdr.p_type != PT_LOAD) {
            continue;
        }

        printf("Loading segment %d: vaddr=0x%08x, size=%u bytes\n", 
               i, (uint32_t)phdr.p_vaddr, (uint32_t)phdr.p_filesz);

        // Check address range
        if (phdr.p_vaddr >= CPU_IMEM_SIZE + CPU_DMEM_SIZE) {
            printf("Error: Segment address 0x%08x out of range\n", (uint32_t)phdr.p_vaddr);
            fclose(fp);
            return CPU_ERROR_MEMORY;
        }

        // Allocate buffer for segment data
        uint8_t *segment_data = malloc(phdr.p_filesz);
        if (!segment_data) {
            printf("Error: Cannot allocate memory for segment\n");
            fclose(fp);
            return CPU_ERROR_MEMORY;
        }

        // Read segment data
        long current_pos = ftell(fp);
        fseek(fp, phdr.p_offset, SEEK_SET);
        
        if (fread(segment_data, 1, phdr.p_filesz, fp) != phdr.p_filesz) {
            printf("Error: Cannot read segment data\n");
            free(segment_data);
            fclose(fp);
            return CPU_ERROR_INVALID;
        }

        // Load segment into CPU memory
        int result = cpu_write_memory(phdr.p_vaddr, segment_data, phdr.p_filesz);
        if (result != CPU_SUCCESS) {
            printf("Error: Failed to write segment to CPU memory\n");
            free(segment_data);
            fclose(fp);
            return result;
        }

        // Zero out BSS section if needed
        if (phdr.p_memsz > phdr.p_filesz) {
            size_t bss_size = phdr.p_memsz - phdr.p_filesz;
            printf("Clearing BSS: 0x%08x, size=%u bytes\n", 
                   (uint32_t)(phdr.p_vaddr + phdr.p_filesz), (uint32_t)bss_size);
            cpu_clear_memory(phdr.p_vaddr + phdr.p_filesz, bss_size);
        }

        info->program_size += phdr.p_filesz;
        if (info->load_address == 0) {
            info->load_address = phdr.p_vaddr;
        }

        free(segment_data);
        fseek(fp, current_pos, SEEK_SET);
    }

    fclose(fp);
    return CPU_SUCCESS;
}

/**
 * Load binary file
 */
static int load_binary_file(const char *filename, uint32_t load_addr, program_info_t *info) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        printf("Error: Cannot open binary file %s\n", filename);
        return CPU_ERROR_INVALID;
    }

    // Get file size
    fseek(fp, 0, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    printf("Binary file size: %ld bytes\n", file_size);
    printf("Load address: 0x%08x\n", load_addr);

    // Check address range
    if (load_addr + file_size > CPU_IMEM_SIZE + CPU_DMEM_SIZE) {
        printf("Error: Binary too large for memory\n");
        fclose(fp);
        return CPU_ERROR_MEMORY;
    }

    // Read entire file
    uint8_t *file_data = malloc(file_size);
    if (!file_data) {
        printf("Error: Cannot allocate memory for binary\n");
        fclose(fp);
        return CPU_ERROR_MEMORY;
    }

    if (fread(file_data, 1, file_size, fp) != (size_t)file_size) {
        printf("Error: Cannot read binary file\n");
        free(file_data);
        fclose(fp);
        return CPU_ERROR_INVALID;
    }

    // Load into CPU memory
    int result = cpu_write_memory(load_addr, file_data, file_size);
    if (result != CPU_SUCCESS) {
        printf("Error: Failed to write binary to CPU memory\n");
        free(file_data);
        fclose(fp);
        return result;
    }

    // Set program info
    info->load_address = load_addr;
    info->entry_point = load_addr;
    info->program_size = file_size;

    free(file_data);
    fclose(fp);
    return CPU_SUCCESS;
}

/**
 * Load Intel HEX file
 */
static int load_hex_file(const char *filename, program_info_t *info) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        printf("Error: Cannot open HEX file %s\n", filename);
        return CPU_ERROR_INVALID;
    }

    char line[256];
    uint32_t base_addr = 0;
    uint32_t min_addr = 0xFFFFFFFF;
    uint32_t max_addr = 0;
    int line_num = 0;

    while (fgets(line, sizeof(line), fp)) {
        line_num++;
        
        // Skip empty lines and comments
        if (line[0] != ':') {
            continue;
        }