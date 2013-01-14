all:
	./build.sh
	./run_benchmarks.sh
	python format_results.py

loc:
	./loc.sh