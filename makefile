shfbt: main.o globals.o fonts.o
	@rgblink -o shfbt.gb main.o globals.o fonts.o
	@echo "Linking object files into image..."
	@rgbfix -v -p 0 shfbt.gb
	@echo "Tidying up image..."
	@echo "Image made successfully."
        
main.o:
	@rgbasm -o main.o main.asm
	@echo "Making main..."
    
globals.o:
	@rgbasm -o globals.o globals.asm
	@echo "Making globals..."

fonts.o:
	@rgbasm -o fonts.o globals.asm
	@echo "Making fonts..."
    
clean:
	@rm main.o globals.o fonts.o shfbt.gb
	@echo "Directory cleaned."