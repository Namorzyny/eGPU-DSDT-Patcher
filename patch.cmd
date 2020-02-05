@echo off
setlocal enabledelayedexpansion

:extract
rd /s /q data 2> nul
md data
cd data
..\iasl\acpidump -bz 2> nul
..\iasl\iasl -p dsdt -d dsdt.dat 2> nul
cd ..

for /f "delims=:" %%n in ('busybox grep -n "Device (PCI0)" ./data/dsdt.dsl') do (
	set line=%%n
	goto :search2
)

:search2
for /f "delims=:" %%n in ('busybox grep -n "Name (BUF0, ResourceTemplate ()" ./data/dsdt.dsl') do (
	if %%n gtr %line% (
		set line=%%n
		goto :search3
	)
)

:search3
for /f "delims=:" %%n in ('busybox grep -n "})" ./data/dsdt.dsl') do (
	if %%n gtr %line% (
		set /a line=%%n
		goto :patch
	)
)

:patch
set /a line2=%line%-1
busybox head -n %line2% ./data/dsdt.dsl > ./data/dsdt_patched.dsl
busybox cat snippet.txt >> ./data/dsdt_patched.dsl
busybox tail -n +%line% ./data/dsdt.dsl >> ./data/dsdt_patched.dsl

:compile
cd data
..\iasl\iasl -ve dsdt_patched.dsl 2> nul
cd ..

:loadtable
asl /loadtable ./data/dsdt_patched.aml

:enable
bcdedit -set TESTSIGNING ON
