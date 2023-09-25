//Noam lahmani
#include <stdlib.h>
#include <stdbool.h>
#include "myfunction1.h"
#include "showBMP.h"


/*
 * initialize_pixel_sum - Initializes all fields of sum to 0
 */
void initialize_pixel_sum(pixel_sum* sum) {
	sum->red = sum->green = sum->blue = 0;
	// sum->num = 0;
	return;
}

/*
 * assign_sum_to_pixel - Truncates pixel's new value to match the range [0,255]
 */
static void assign_sum_to_pixel(pixel* current_pixel, pixel_sum sum, int kernelScale) {

	// divide by kernel's weight
	sum.red = sum.red / kernelScale;
	sum.green = sum.green / kernelScale;
	sum.blue = sum.blue / kernelScale;

	// truncate each pixel's color values to match the range [0,255]

	current_pixel->red = (unsigned char)((sum.red > 0 ? sum.red : 0) < 255 ? (
		sum.red > 0 ? sum.red : 0) : 255);
	current_pixel->green = (unsigned char)((sum.green > 0 ? sum.green : 0) < 255 ? (
		sum.green > 0 ? sum.green : 0) : 255);
	current_pixel->blue = (unsigned char)((sum.blue > 0 ? sum.blue : 0) < 255 ? (
		sum.blue > 0 ? sum.blue : 0) : 255);

	return;
}

/*
* sum_pixels_by_weight - Sums pixel values, scaled by given weight
*/
static void sum_pixels_by_weight(pixel_sum* sum, pixel p, int weight) {
	sum->red += ((int)p.red) * weight;
	sum->green += ((int)p.green) * weight;
	sum->blue += ((int)p.blue) * weight;
	// sum->num++;
	return;
}

/*
 * Applies kernel for pixel at (i,j)
 */
static pixel applyKernel(int dim, int i, int j, pixel* src, int kernelSize, int kernel[kernelSize][kernelSize], int kernelScale, bool filter) {

	int ii, jj;
	int currRow, currCol;
	pixel_sum sum;
	pixel current_pixel;
	int min_intensity = 766; // arbitrary value that is higher than maximum possible intensity, which is 255*3=765
	int max_intensity = -1; // arbitrary value that is lower than minimum possible intensity, which is 0
	int min_row, min_col, max_row, max_col;
	pixel loop_pixel;

	initialize_pixel_sum(&sum);
	// sum->red = sum->green = sum->blue = 0;
	int ii_max = (i - 1 > 0 ? i - 1 : 0);
	int ii_min = (i + 1 < dim - 1 ? i + 1 : dim - 1);
	int jj_max = (j - 1 > 0 ? j - 1 : 0);
	int jj_min = (j + 1 < dim - 1 ? j + 1 : dim - 1);
	for (ii = ii_max; ii <= ii_min; ii++) {
		for (jj = jj_max; jj <= jj_min; jj++) {

			int kRow, kCol;

			// compute row index in kernel
			if (ii < i) {
				kRow = 0;
			}
			else if (ii > i) {
				kRow = 2;
			}
			else {
				kRow = 1;
			}

			// compute column index in kernel
			if (jj < j) {
				kCol = 0;
			}
			else if (jj > j) {
				kCol = 2;
			}
			else {
				kCol = 1;
			}

			// apply kernel on pixel at [ii,jj]
			sum_pixels_by_weight(&sum, src[((ii) * (dim)) + (jj)], kernel[kRow][kCol]);
		}
	}

	if (filter) {
		// find min and max coordinates
		for (ii = ii_max; ii <= ii_min; ii++) {
			for (jj = jj_max; jj <= jj_min; jj++) {
				// check if smaller than min or higher than max and update
				loop_pixel = src[((ii) * (dim)) + (jj)];
				if ((((int)loop_pixel.red) + ((int)loop_pixel.green) + ((int)loop_pixel.blue)) <= min_intensity) {
					min_intensity = (((int)loop_pixel.red) + ((int)loop_pixel.green) + ((int)loop_pixel.blue));
					min_row = ii;
					min_col = jj;
				}
				if ((((int)loop_pixel.red) + ((int)loop_pixel.green) + ((int)loop_pixel.blue)) > max_intensity) {
					max_intensity = (((int)loop_pixel.red) + ((int)loop_pixel.green) + ((int)loop_pixel.blue));
					max_row = ii;
					max_col = jj;
				}
			}
		}
		// filter out min and max
		sum_pixels_by_weight(&sum, src[((min_row) * (dim)+(min_col))], -1);
		sum_pixels_by_weight(&sum, src[((max_row) * (dim)+(max_col))], -1);
	}

	// assign kernel's result to pixel at [i,j]
	assign_sum_to_pixel(&current_pixel, sum, kernelScale);
	return current_pixel;
}

/*
* Apply the kernel over each pixel.
* Ignore pixels where the kernel exceeds bounds. These are pixels with row index smaller than kernelSize/2 and/or
* column index smaller than kernelSize/2
*/
void smooth(int dim, pixel* src, pixel* dst, int kernelSize, int kernel[kernelSize][kernelSize], int kernelScale, bool filter)
{

	int i, j;
	int newKernelSize = kernelSize >> 1; //half of the kernel scale - kernelSize / 2;
	int scope = dim - newKernelSize; //n - kernelSize / 2
	int weight = kernel[0][0]; //1 or -1

	pixel p1, p2, p3, p_middle;
	pixel_sum c1, c2, c3, sumWeights;

	//variables for "if filter"
	int ii, jj;
	int firstCol, secondCol, thirdCol; //j-1, j, j+1
	int firstRow, secondRow, thirdRow; //i-1, i, i+1
	int min_intensity = 766, max_intensity = -1;
	int min_row, min_col, max_row, max_col;
	int loop_pixel_sum;
	int scope_ii, scope_jj;
	int index_min, index_max, index;
	int lim; //j+2
	pixel loop_pixel;

	if (weight == 1 || weight == -1) {
		//Calculate each pixel in three columns of the kernel scale
		//and sum the pixels in each column
		for (i = newKernelSize; i < scope; ++i) {
			firstRow = i - 1;
			secondRow = i;
			thirdRow = i + 1;

			j = newKernelSize;
			firstCol = j - 1;
			secondCol = j;
			thirdCol = j + 1;

			//first column of the kernel scale
			//pixels in first colum
			p1 = src[firstRow * dim + firstCol];
			p2 = src[secondRow * dim + firstCol];
			p3 = src[thirdRow * dim + firstCol];
			//The sum of all the pixels of each color in the first column
			//and multiplication by the weight
			c1.red = (int)(p1.red + p2.red + p3.red);
			c1.green = (int)(p1.green + p2.green + p3.green);
			c1.blue = (int)(p1.blue + p2.blue + p3.blue);

			//middle column of the kernel scale
			//pixels in middle colum
			p1 = src[firstRow * dim + secondCol];
			p2 = src[secondRow * dim + secondCol];
			p3 = src[thirdRow * dim + secondCol];

			//The sum of all the pixels of each color in the middle column
			//and multiplication by the weight
			c2.red = (int)(p1.red + p2.red + p3.red);
			c2.green = (int)(p1.green + p2.green + p3.green);
			c2.blue = (int)(p1.blue + p2.blue + p3.blue);

			//last column
			//pixels in last colum
			p1 = src[firstRow * dim + thirdCol];
			p2 = src[secondRow * dim + thirdCol];
			p3 = src[thirdRow * dim + thirdCol];

			//The sum of all the pixels of each color in the last column
			//and multiplication by the weight
			c3.red = (int)(p1.red + p2.red + p3.red);
			c3.green = (int)(p1.green + p2.green + p3.green);
			c3.blue = (int)(p1.blue + p2.blue + p3.blue);

			if (weight == -1) //Multiply the color of the column by weight
			{
				c1.red = -c1.red;
				c1.green = -c1.green;
				c1.blue = -c1.blue;

				c2.red = -c2.red;
				c2.green = -c2.green;
				c2.blue = -c2.blue;

				c3.red = -c3.red;
				c3.green = -c3.green;
				c3.blue = -c3.blue;
			}

			for (j = newKernelSize; j < scope; ++j) {

				//The sum of all the pixels of each color in the whole kernel scale
				sumWeights.red = c1.red + c2.red + c3.red;
				sumWeights.blue = c1.blue + c2.blue + c3.blue;
				sumWeights.green = c1.green + c2.green + c3.green;

				p_middle = src[i * dim + j];

				if (weight == -1) //sumWeight.color += middle * 10
				{
					// x*10 == x* 2^3 + x* 2^1 = 8x + 2x
					sumWeights.red = sumWeights.red + (int)((p_middle.red << 3) + (p_middle.red << 1));
					sumWeights.green = sumWeights.green + ((p_middle.green << 3) + (p_middle.green << 1));
					sumWeights.blue = sumWeights.blue + ((p_middle.blue << 3) + (p_middle.blue << 1));
				}
				if (filter) {
					min_intensity = 766;
					max_intensity = -1;
					scope_ii = kernelSize + i - 1;
					scope_jj = kernelSize + j - 1;

					//Find the minimum value and the maximum value
					//from the values of the pixels
					for (ii = i - 1; ii < scope_ii; ++ii) {
						for (jj = j - 1; jj < scope_jj; ++jj) {
							loop_pixel = src[ii * dim + jj];
							loop_pixel_sum = (int)(loop_pixel.blue + loop_pixel.green + loop_pixel.red);
							if (loop_pixel_sum <= min_intensity) {
								min_intensity = loop_pixel_sum;
								min_row = ii;
								min_col = jj;
							}
							if (loop_pixel_sum > max_intensity) {
								max_intensity = loop_pixel_sum;
								max_row = ii;
								max_col = jj;
							}
						}
					}

					index_max = max_row * dim + max_col;
					index_min = min_row * dim + min_col;

					//Subtract the minimum and maximum value from sum weight
					sumWeights.red = sumWeights.red - src[index_min].red - src[index_max].red;
					sumWeights.green = sumWeights.green - src[index_min].green - src[index_max].green;
					sumWeights.blue = sumWeights.blue - src[index_min].blue - src[index_max].blue;
				}
				if (filter) {
					sumWeights.red = sumWeights.red / 7;
					sumWeights.blue = sumWeights.blue / 7;
					sumWeights.green = sumWeights.green / 7;
				}

				//assign sum to pixel
				else if (!filter && weight == 1) {
					sumWeights.red = sumWeights.red / 9;
					sumWeights.blue = sumWeights.blue / 9;
					sumWeights.green = sumWeights.green / 9;
				}
				else {
					sumWeights.red = sumWeights.red / kernelScale;
					sumWeights.blue = sumWeights.blue / kernelScale;
					sumWeights.green = sumWeights.green / kernelScale;
				}

				index = i * dim + j;

				if (weight == 1) //sumWeights.red,blue,green >=0
				{
					dst[index].red = (unsigned char)(sumWeights.red < 255 ? sumWeights.red : 255);
					dst[index].green = (unsigned char)(sumWeights.green < 255 ? sumWeights.green : 255);
					dst[index].blue = (unsigned char)(sumWeights.blue < 255 ? sumWeights.blue : 255);

				}
				else if (weight == -1) {
					dst[i * dim + j].red = (unsigned char)((sumWeights.red > 0 ? sumWeights.red : 0) < 255 ? (
						sumWeights.red > 0 ? sumWeights.red : 0) : 255);
					dst[i * dim + j].green = (unsigned char)((sumWeights.green > 0 ? sumWeights.green : 0) < 255 ? (
						sumWeights.green > 0 ? sumWeights.green : 0) : 255);
					dst[i * dim + j].blue = (unsigned char)((sumWeights.blue > 0 ? sumWeights.blue : 0) < 255 ? (
						sumWeights.blue > 0 ? sumWeights.blue : 0) : 255);
				}

				c1 = c2;
				c2 = c3;
				lim = j + 2;
				if (lim < dim) {

					//if the kernel has an additional col
					p1 = src[firstRow * dim + lim];
					p2 = src[secondRow * dim + lim];
					p3 = src[thirdRow * dim + lim];
					// c1 and c2 already changed
					c3.red = (int)(p1.red + p2.red + p3.red);
					c3.green = (int)(p1.green + p2.green + p3.green);
					c3.blue = (int)(p1.blue + p2.blue + p3.blue);

					if (weight == -1) {
						c3.red = -c3.red; //* weight
						c3.green = -c3.green;
						c3.blue = -c3.blue;
					}
				}

			}
		}
	}

	else if (weight == 0) {
		for (i = newKernelSize; i < scope; i++) {
			for (j = newKernelSize; j < scope; j++) {
				dst[((i) * (dim)) + (j)] = applyKernel(dim, i, j, src, kernelSize, kernel, kernelScale, filter);
			}
		}
	}

}

void charsToPixels(Image* charsImg, pixel* pixels) {

	int row, col, rn, rnc, r3n, c3, r3nc3;
	for (row = 0; row < m; row++) {
		rn = row * n;
		r3n = (rn << 1) + rn;
		for (col = 0; col < n; col++) {
			rnc = rn + col;
			c3 = (col << 1) + col;
			r3nc3 = r3n + c3;
			pixels[rnc].red = image->data[r3nc3];
			pixels[rnc].green = image->data[r3nc3 + 1];
			pixels[rnc].blue = image->data[r3nc3 + 2];
		}
	}
}


void pixelsToChars(pixel* pixels, Image* charsImg) {

	int row, col;
	int rn, r3n, c3, r3nc3, rnc;
	for (row = 0; row < m; row++) {
		rn = row * n;
		r3n = (rn << 1) + rn;
		for (col = 0; col < n; col++) {
			rnc = rn + col;
			c3 = (col << 1) + col;
			r3nc3 = r3n + c3;
			image->data[r3nc3] = pixels[rnc].red;
			image->data[r3nc3 + 1] = pixels[rnc].green;
			image->data[r3nc3 + 2] = pixels[rnc].blue;
		}
	}
}

void copyPixels(pixel* src, pixel* dst) {

	int row, col, rn, rnc;
	for (row = 0; row < m; row++) {
		rn = row * n;
		for (col = 0; col < n; col++) {
			rnc = rn + col;
			dst[rnc].red = src[rnc].red;
			dst[rnc].green = src[rnc].green;
			dst[rnc].blue = src[rnc].blue;
		}
	}
}


void doConvolution(Image* image, int kernelSize, int kernel[kernelSize][kernelSize], int kernelScale, bool filter) {
	int sizeOfPizel = sizeof(pixel);
	int mn = m * n;
	int mnSize = mn * sizeOfPizel;
	pixel* pixelsImg = malloc(mnSize);
	pixel* backupOrg = malloc(mnSize);

	charsToPixels(image, pixelsImg);
	copyPixels(pixelsImg, backupOrg);

	smooth(m, backupOrg, pixelsImg, kernelSize, kernel, kernelScale, filter);

	pixelsToChars(pixelsImg, image);

	free(pixelsImg);
	free(backupOrg);
}


