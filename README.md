# JainSheet

A fully featured desktop spreadsheet application built with Electron.

## Features
- 26 columns × 100 rows grid
- Multi-sheet tabs
- Full formula engine (50+ functions including SUM, VLOOKUP, IF, etc.)
- Formula autocomplete when typing `=`
- Save as `.xlsx`, `.xls`, `.json`, `.csv`
- Import CSV
- Dark mode
- Column & row resize
- Charts (Bar, Line, Pie, Area)
- Cell formatting, comments, conditional formatting
- Print to PDF
- Auto-save
- Undo / Redo

## Tech Stack
- Electron v34
- Vanilla JavaScript (no frameworks)
- SheetJS (xlsx) for Excel export

## Setup
```bash
cd JainSheet
npm install
npm start
```

## Build .exe
```bash
npm run dist
```
Output: `dist/JainSheet-Setup.exe`

## Project Path
`D:\JainSheet\`

## Version
v2.0.0
