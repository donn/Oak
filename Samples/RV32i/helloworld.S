    addi a0, zero, str
    addi a7, zero, 4 #4 is the string print service number...
    ecall
    addi a7, zero, 10 #...and 10 is the program termination service number!
    ecall
.data
str:    .string "Hello, World!"