shfbt: main.o globals.o fonts.o opening_screens.o opening_maps.o\
			controller.o lcd_interface.o
	@echo "Linking object files into image..."
	rgblink -o shfbt.gb ./src/*.o
	@echo "Tidying up image..."
	@rgbfix -v -p 0 shfbt.gb
	@echo "Image made successfully."

main.o:
	@echo "Making main..."
	@rgbasm -i ./src/fonts/ -i ./src/ -i ./src/maps/ -o ./src/main.o ./src/main.asm

globals.o:
	@echo "Making globals..."
	@rgbasm -o ./src/globals.o ./src/globals.asm


lcd_interface.o:
	@echo "Making lcd_interface..."
	@rgbasm -i ./src/ -o ./src/lcd_interface.o ./src/lcd_interface.asm

controller.o:
	@echo "Making contoller..."
	@rgbasm -i ./src/ -o ./src/controller.o ./src/controller.asm

fonts.o:
	@echo "Making fonts..."
	@rgbasm -i ./src/ -o ./src/fonts/fonts.o ./src/fonts/fonts.asm

opening_screens.o:
	@echo "Making opening screens..."
	@rgbasm -i ./src/ -i ./src/fonts/ -o ./src/opening_screens.o ./src/opening_screens.asm

opening_maps.o:
	@echo "Making opening_maps..."
	@rgbasm -i ./src/ -o ./src/maps/opening_maps.o ./src/maps/opening_maps.asm

clean:
	@rm ./src/*.o ./src/fonts/*.o ./*.gb
	@echo "Directory cleaned."
