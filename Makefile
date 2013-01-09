all:
	./build.sh
	./run_benchmarks.sh
	python tabulate.py

loc:
	./loc.sh