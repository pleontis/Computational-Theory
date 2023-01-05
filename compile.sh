#!/bin/bash
#Script for running flex commands
#First argument is the lexer file
#Second argument is the Theta code file to be compiled

#Check if every file given exists
for fp in $* 
do  
    if [ ! -f "$fp" ]; then
        echo "File: $fp does not exist. Terminating programm"
        exit;
    fi 
done

#Now execute commands given for compiling Theta Program
bison -d -v -r all $1
flex $2
gcc -o mylexer lex.yy.c myanalyzer.tab.c cgen.c -lfl
./mylexer < $3

#Compiling and running c-translated programm
#Use gcc
gcc -o c_executable translatedFile.c -lm

./c_executable
