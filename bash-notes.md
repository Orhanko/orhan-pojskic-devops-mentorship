# TASK-2: LINUX-UNIX-bandit-labs

## Commands

### ssh banditX@bandit.labs.overthewire.org -p 2220

- komanda za login na sever na portu 2220.

### cat <filename>

- komanda za ispis fajla koju smo koristili kako bi dobili password za naredni level.

### ls || ls -la

- komanda za ispis fajlova ili foldera unutar direkotrija u kojem se nalazimo. Dodatni dio "-la" nam ispisuje i skrivene fajlove.

### cd <filename>

- komanda za navigiranje u određeni fajl.

### cat < -

- komadna za ispis fajla pod nazviom "-".

### cat <dionaziva>\ <dionaziva>\ <dionaziva>\ <dionaziva>

- komanda za ispis fajla koji u imeni sadrži razmake.

### find. -type f ! -executable -size <bytesize>

- komanda za ispis fajla za određenim specifikacijama (not executable, size of file).

### grep "sadržajkojitražimo" <filename>

- komanda kojom tražimo određni sadržaj unutar fajla.

### cat data.txt | sort | uniq -u

- komanda za ispis dijela fajla koji je unikatan, ne ponavlja se nijednom unutar fajla.

### strings data.txt I grep "sadržaj"

### base64 -d data. txt