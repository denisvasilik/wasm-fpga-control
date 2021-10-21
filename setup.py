import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

__tag__ = ""
__build__ = 0
__version__ = "{}".format(__tag__)
__commit__ = "0000000"

setuptools.setup(
    name="wasm-fpga-control",
    version=__version__,
    author="Denis Vasilìk",
    author_email="contact@denisvasilik.com",
    url="https://github.com/denisvasilik/wasm-fpga-control/",
    project_urls={
        "Bug Tracker": "https://github.com/denisvasilik/wasm-fpga/",
        "Documentation": "https://wasm-fpga.readthedocs.io/en/latest/",
        "Source Code": "https://github.com/denisvasilik/wasm-fpga-control/",
    },
    description="WebAssembly FPGA Control",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "Operating System :: OS Independent",
    ],
    dependency_links=[],
    package_dir={},
    package_data={},
    data_files=[(
        "wasm-fpga-control/package", [
            "package/component.xml"
        ]),(
        "wasm-fpga-control/package/bd", [
            "package/bd/bd.tcl"
        ]),(
        "wasm-fpga-control/package/xgui", [
            "package/xgui/wasm_fpga_control_v1_0.tcl"
        ]),(
        "wasm-fpga-control/resources", [
            "resources/wasm_fpga_loader_header.vhd",
            "resources/wasm_fpga_engine_header.vhd",
        ]),(
        "wasm-fpga-control/src", [
            "src/WasmFpgaControl.vhd",
            "src/WasmFpgaControlPackage.vhd",
        ]),(
        "wasm-fpga-control/tb", [
            "tb/tb_pkg_helper.vhd",
            "tb/tb_pkg.vhd",
            "tb/tb_std_logic_1164_additions.vhd",
            "tb/tb_Types.vhd",
            "tb/tb_FileIo.vhd",
            "tb/tb_WasmFpgaControl.vhd",
        ]),(
        'wasm-fpga-control/simstm', [
            'simstm/Defines.stm',
            'simstm/WasmFpgaControl.stm',
        ]),(
        "wasm-fpga-control", [
            "CHANGELOG.md",
            "AUTHORS",
            "LICENSE"
        ])
    ],
    setup_requires=[],
    install_requires=[],
    entry_points={},
)
