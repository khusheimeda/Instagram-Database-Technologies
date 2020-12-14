#!/usr/bin/python3
import sys

for line in sys.stdin:
	line = line.strip()
	words = line.split(',')
	if (float(words[len(words) - 1]) > 50):
		print("G", 1)
	else:
		print("C", 1)
	
