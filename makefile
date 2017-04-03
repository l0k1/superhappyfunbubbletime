#A simple make file.
#Use "make" just to create the rom, or use "make debug" to create symbol files.
#To clean the directories of the ROM, object files, and everything make made, use "make clean".

CC = rgbasm
CFLAGS = -i ./src/ -i ./src/fonts/ -i ./src/maps/ -i ./src/tiles/
LINK = rgblink
FIX = rgbfix
FFLAGS = -v -p 0
OUTPUT_NAME=shfbt

SOURCES=./src/interrupts.asm\
		./src/globals.asm\
		./src/lcd_interface.asm\
		./src/main.asm\
		./src/opening_screens.asm\
		./src/world_interface.asm\
		./src/camera.asm\
		./src/fonts/fonts.asm\
		./src/maps/opening_maps.asm\
		./src/maps/field_of_testing.asm\
		./src/tiles/pointer.asm\
		./src/tiles/landscape.asm\
		./src/sprites/main_character.asm
OBJECTS=$(SOURCES:.asm=.o)



shfbt: $(OBJECTS)
	@echo "Linking object files into image..."
	@$(LINK) -o $(OUTPUT_NAME).gb $(OBJECTS)
	@echo "Tidying up image..."
	@$(FIX) $(FFLAGS) -v -p 0 shfbt.gb
	@echo "ROM assembly complete."

debug:	$(OBJECTS)
	@echo "Linking object files into image..."
	@echo "Creating symbol and map files for debugging..."
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
