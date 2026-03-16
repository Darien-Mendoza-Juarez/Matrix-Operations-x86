# Matrix-Operations-x86

x86 Assembly matrix operator built with TASM. Supports addition, transpose, main diagonal, element/row/column sums. Developed for DOS environment using DOSBox. Multiplication incomplete.

---

## Operations

| Option | Operation | Status |
|--------|-----------|--------|
| A | Sum of two matrices |  Working |
| B | Transpose |  Working |
| C | Matrix multiplication |  Incomplete |
| D | Main diagonal + total sum |  Working |
| E | Column sums |  Working |
| F | Row sums |  Working |

---

## Requirements

- [DOSBox](https://www.dosbox.com/download.php?main=1)
- All other tools are included in the `env/` folder — no separate installation needed.

---

## Project Structure

```
/
├── MAIN.asm              # Entry point, menu and program flow
├── MATRICES.asm          # Matrix operation implementations
├── PROCEDIMIENTOS.asm    # General-purpose procedures
├── macros.inc            # Macro definitions
└── env/                  # DOS tools (TASM, TLINK, TD, dependencies)
    ├── TASM.EXE          # Turbo Assembler
    ├── TLINK.EXE         # Turbo Linker
    ├── td.exe            # Turbo Debugger
    ├── debug.exe         # DOS Debugger
    ├── RTM.EXE           # Runtime Manager (required by TASM)
    ├── TLIB.EXE          # Turbo Librarian
    ├── DPMI16BI.OVL      # DPMI support (16-bit)
    └── DPMI32VM.OVL      # DPMI support (32-bit)
```

---

## Setup

### 1. Configure DOSBox

Mount the project folder inside DOSBox and add `env/` to the PATH so the tools are accessible from anywhere:

```
mount c path\to\project
c:
set PATH=%PATH%;C:\env
```

### 2. Assemble each file

```
tasm MAIN.asm
tasm MATRICES.asm
tasm PROCEDIMIENTOS.asm
```

Each command produces a `.OBJ` file.

### 3. Link

```
tlink MAIN.OBJ MATRICES.OBJ PROCEDIMIENTOS.OBJ
```

This produces `MAIN.EXE`.

### 4. Run

```
MAIN.EXE
```

---

## Debugging with Turbo Debugger

To assemble with debug information, add the `/zi` flag:

```
tasm /zi MAIN.asm
tasm /zi MATRICES.asm
tasm /zi PROCEDIMIENTOS.asm
tlink /v MAIN.OBJ MATRICES.OBJ PROCEDIMIENTOS.OBJ
td MAIN.EXE
```

---

## Notes

- Matrix size is fixed at 4x4.
- Input is entered row by row, values separated by commas.
- Matrix multiplication (option C) is not yet implemented.
- Developed for the course *Estructura y Programación de Computadoras* — UNAM Facultad de Ingeniería.
