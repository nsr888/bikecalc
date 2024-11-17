# bikecalc - Command line gear inch calculator for bicycle gearing written in Bash

A lightweight command-line gear inch calculator for bicycle gearing, written in Bash, designed for cyclists and developers.

# Requirements

- Bash v4.4 or higher

# Usage

```bash
$ ./bikecalc.sh
```

Script will prompt you to enter values and will display table with gear inches
for 3 chainrings and all cogs.

Sample output:

```bash
Summary:
Rim diameter: 584
Tire diameter: 57.15
First chainring: 22
Second chainring: 32
Third chainring: 44
Minimum cog: 11
Maximum cog: 32
+---------------------------------------------------+
| Ring/Cog   | 22         | 32         | 44         |
|---------------------------------------------------|
| 11         | 54.98      | 79.72      | 109.96     |
| 12         | 50.30      | 73.12      | 100.61     |
| 13         | 46.45      | 67.62      | 92.91      |
| 14         | 43.15      | 62.67      | 86.31      |
| 15         | 40.13      | 58.55      | 80.54      |
| 16         | 37.66      | 54.98      | 75.59      |
| 17         | 35.46      | 51.68      | 70.92      |
| 18         | 33.53      | 48.65      | 67.07      |
| 19         | 31.61      | 46.18      | 63.50      |
| 20         | 30.23      | 43.98      | 60.47      |
| 21         | 28.58      | 41.78      | 57.45      |
| 22         | 27.49      | 39.86      | 54.98      |
| 23         | 26.11      | 38.21      | 52.50      |
| 24         | 25.01      | 36.56      | 50.30      |
| 25         | 24.19      | 35.18      | 48.38      |
| 26         | 23.09      | 33.81      | 46.45      |
| 27         | 22.26      | 32.43      | 44.53      |
| 28         | 21.44      | 31.33      | 43.15      |
| 29         | 20.61      | 30.23      | 41.50      |
| 30         | 20.06      | 29.13      | 40.13      |
| 31         | 19.24      | 28.31      | 38.76      |
| 32         | 18.69      | 27.49      | 37.66      |
+---------------------------------------------------+
```

# Features

- Calculate gear inches for a given chainring and cog combination

# Links

- [Inspired by bikecalc.com](https://www.bikecalc.com/archives/gear-inches.html)
