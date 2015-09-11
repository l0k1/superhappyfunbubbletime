shfbt: ./src/main.o ./src/globals.o ./src/fonts.o
	@rgblink -o shfbt.gb ./src/main.o ./src/globals.o ./src/fonts/fonts.o
	@echo "Linking object files into image..."
	@rgbfix -v -p 0 shfbt.gb
	@echo "Tidying up image..."
	@echo "Image made successfully."
        
./src/main.o:
	@rgbasm -i ./src/ -i ./src/fonts/ -o ./src/main.o ./src/main.asm
	@echo "Making main..."
    
./src/globals.o:
	@rgbasm -o ./src/globals.o ./src/globals.asm
	@echo "Making globals..."

./src/fonts.o:
	@rgbasm -o ./src/fonts/fonts.o ./src/fonts/fonts.asm
	@echo "Making fonts..."
    
clean:
	@rm ./src/*.o ./src/fonts/*.o shfbt.gb
	@echo "Directory cleaned."
