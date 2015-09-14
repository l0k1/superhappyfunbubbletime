shfbt: main.o globals.o fonts.o opening_screens.o opening_maps.o\
			controller.o lcd_interface.o
	@rgblink -o shfbt.gb ./src/main.o ./src/globals.o ./src/fonts/fonts.o ./src/opening_screens.o ./src/controller.o ./src/lcd_interface.o
#	rgblink -o shfbt.gb ./src/*.o
	@echo "Linking object files into image..."
	@rgbfix -v -p 0 shfbt.gb
	@echo "Tidying up image..."
	@echo "Image made successfully."

main.o:
	@rgbasm -i ./src/fonts/ -i ./src/ -i ./src/maps/ -o ./src/main.o ./src/main.asm
	@echo "Making main..."

globals.o:
	@rgbasm -o ./src/globals.o ./src/globals.asm
	@echo "Making globals..."

lcd_interface.o:
	@rgbasm -i ./src/ -o ./src/lcd_interface.o ./src/lcd_interface.asm
	@echo "Making lcd_interface..."

controller.o:
	@rgbasm -i ./src/ -o ./src/controller.o ./src/controller.asm
	@echo "Making contoller..."

fonts.o:
	@rgbasm -i ./src/ -o ./src/fonts/fonts.o ./src/fonts/fonts.asm
	@echo "Making fonts..."

opening_screens.o:
	@rgbasm -i ./src/ -i ./src/fonts/ -o ./src/opening_screens.o ./src/opening_screens.asm
	@echo "Making opening screens..."

opening_maps.o:
	@rgbasm -i ./src/ -o ./src/maps/opening_maps.o ./src/maps/opening_maps.asm
	@echo "Making opening_maps..."

clean:
	@rm ./src/*.o ./src/fonts/*.o ./*.gb
	@echo "Directory cleaned."
