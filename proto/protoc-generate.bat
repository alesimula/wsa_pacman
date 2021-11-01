@echo off
if not exist "..\lib\proto\" mkdir ..\lib\proto
protoc --dart_out=../lib/proto/ *.proto