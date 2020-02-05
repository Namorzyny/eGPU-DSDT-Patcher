@echo off
asl /loadtable ./data/dsdt_patched.aml -d
bcdedit -set TESTSIGNING OFF
