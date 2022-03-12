////////////////////////////////////////////////////////////////////////////////////////////////////////
// Indices RGB
// 
// Red-Green-Blue Vegetation Index (RGBVI) (Bendig et al 2015)
//
// Autor: Gustavo Pereyra Irujo - pereyrairujo.gustavo@conicet.gov.ar
// Licencia GNU AFFERO GENERAL PUBLIC LICENSE Version 3
// https://github.com/gpereyrairujo/Indices_RGB
//

setBatchMode(true);

// chequeos generales para todos los índices
nombre = getTitle();

// chequear si es un stack de imágenes
if (nSlices>1) {

	// si el stack tiene 4 canales, eliminar el canal 4 (probablemenente el canal 'alpha')
	if (nSlices==4) {
		setSlice(4);
		run("Delete Slice", "delete=channel");		
	}

	// si el stack no tiene 3 o 4 canales, dar error
	if (nSlices!=3) {
		exit("La imagen no tiene 3 o 4 canales (RGB o RGBA)")
	}
	
	// si el stack tiene 3 canales, convertir a RGB para procesar
	if (nSlices==3) {
		run("RGB Color");
		rename("imagen_rgb");
	}
}

// si no es un stack de imágenes
else {
	
	// chequear si es una imagen RGB
	if (indexOf(getInfo(), "Bits per pixel: 32 (RGB)") < 0) {
		exit("La imagen no es RGB")
	}

	// si es una imagen RGB, hacer una copia para procesar
	run("Duplicate...", "title=imagen_rgb");
}


// cálculo del índice

// separar canales y convertir las imágenes a 32 bits
run("Split Channels");
selectWindow("imagen_rgb (red)");
rename('_r');
run("32-bit");
selectWindow("imagen_rgb (green)");
rename('_g');
run("32-bit");
selectWindow("imagen_rgb (blue)");
rename('_b');
run("32-bit");

// calcular índice
selectWindow("_g");
run("Square");
rename("_g2");
imageCalculator("Multiply create 32-bit", "_r", "_b");
rename("_rb");
imageCalculator("Subtract create 32-bit", "_g2", "_rb");
rename("_g2-rb");
imageCalculator("Add create 32-bit", "_g2", "_rb");
rename("_g2+rb");
imageCalculator("Divide create 32-bit", "_g2-rb", "_g2+rb");
rename("_indice");

// cerrar ventanas
selectWindow("_r");
close();
selectWindow("_g2");
close();
selectWindow("_b");
close();
selectWindow("_rb");
close();
selectWindow("_g2-rb");
close();
selectWindow("_g2+rb");
close();

// resultado
selectWindow("_indice");
rename("RGBVI_" + nombre);
run("Enhance Contrast", "saturated=0.35");
setBatchMode(false);
