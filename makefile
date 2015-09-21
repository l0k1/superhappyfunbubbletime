CC = rgbasm
CFLAGS = -i ./src/ -i ./src/fonts/ -i ./src/maps/
LINK = rgblink
FIX = rgbfix
FFLAGS = -v -p 0
OUTPUT_NAME=shfbt

remake: clean shfbt

shfbt:
	@echo "Assembling..."
	@$(CC) $(CFLAGS) -o ./src/main.o ./src/main.asm
	@echo "Linking object files into image..."
	@$(LINK) -m $(OUTPUT_NAME).map -n $(OUTPUT_NAME).sym -o $(OUTPUT_NAME).gb ./src/main.o
	@echo "Tidying up image..."
	@$(FIX) $(FFLAGS) -v -p 0 shfbt.gb
	@echo "ROM assembly complete."

clean:
	-@rm ./src/main.o ./$(OUTPUT_NAME).* 2> /dev/null || true
	@echo "Directory cleaned."
