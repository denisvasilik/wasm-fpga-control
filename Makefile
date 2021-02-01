PWD=$(shell pwd)

all: package

prepare:
	@mkdir -p work

hxs: fetch-definitions


project: prepare fetch-definitions
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package:
	python3 setup.py sdist bdist_wheel

clean:
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		resources/*

fetch-definitions:
	cp ../wasm-fpga-loader/resources/wasm_fpga_loader_header.vhd \
	resources/wasm_fpga_loader_header.vhd
	cp ../wasm-fpga-engine/resources/wasm_fpga_engine_header.vhd \
	resources/wasm_fpga_engine_header.vhd

install-from-test-pypi:
	pip3 install --upgrade -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple wasm-fpga-control

upload-to-test-pypi: package
	python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*

upload-to-pypi: package
	python3 -m twine upload --repository pypi dist/*

.PHONY: all prepare project package clean fetch-definitions
