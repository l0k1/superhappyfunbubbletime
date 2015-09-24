CC = rgbasm
CFLAGS = -i ./src/ -i ./src/fonts/ -i ./src/maps/ -i ./src/tiles/
LINK = rgblink
FIX = rgbfix
FFLAGS = -v -p 0
OUTPUT_NAME=shfbt

SOURCES=./src/controller.asm\
		./src/globals.asm\
		./src/lcd_interface.asm\
		./src/main.asm\
		./src/opening_screens.asm\
		./src/fonts/fonts.asm\
		./src/maps/opening_maps.asm\
		./src/tiles/pointer.asm
OBJECTS=$(SOURCES:.asm=.o)



shfbt: $(OBJECTS)
#	@echo "Assembling..."
#	@$(CC) $(CFLAGS) -o ./src/main.o ./src/main.asm
	@echo "Linking object files into image..."
	@$(LINK) -m $(OUTPUT_NAME).map -n $(OUTPUT_NAME).sym -o $(OUTPUT_NAME).gb $(OBJECTS)
	@echo "Tidying up image..."
	@$(FIX) $(FFLAGS) -v -p 0 shfbt.gb
	@echo "ROM assembly complete."

%.o:
	@echo "Making " $(@)
	@$(CC) $(CFLAGS) -o $(@) $(@:.o=.asm)

clean:
	-@rm $(OBJECTS) ./$(OUTPUT_NAME).* 2> /dev/null || true
	@echo "Directory cleaned."
