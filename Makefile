PWD=$(shell pwd)

all: package

prepare:
	@mkdir -p work

project: prepare fetch-definitions
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package: prepare
	@vivado -mode batch -source scripts/package_ip.tcl -notrace -nojournal -tempDir work -log work/vivado.log

clean:
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		resources/*

fetch-definitions:
	cp ../wasm-fpga-loader/hxs_gen/vhd_gen/header/wasm_fpga_loader_header.vhd \
	resources/wasm_fpga_loader_header.vhd
	cp ../wasm-fpga-engine/hxs_gen/vhd_gen/header/wasm_fpga_engine_header.vhd \
	resources/wasm_fpga_engine_header.vhd

.PHONY: all prepare project package clean fetch-definitions
