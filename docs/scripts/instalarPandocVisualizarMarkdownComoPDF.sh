# instalando pandoc para visualizar Markdown como PDF
sudo apt-get install pandoc
sudo apt update && sudo apt install texlive-latex-base texlive-latex-recommended

# como usarlo:
pandoc docs/manuals/check_list_deployment.md -o docs/manuals/check_list_deployment.pdf

# Basic PDF with better formatting
pandoc docs/manuals/check_list_deployment.md -o output.pdf --pdf-engine=pdflatex

# PDF with custom margins and font
pandoc docs/manuals/check_list_deployment.md -o output.pdf \
  -V geometry:margin=1in -V fontsize=12pt

# PDF with table of contents
pandoc docs/manuals/check_list_deployment.md -o output.pdf --toc

# Multiple markdown files to one PDF
pandoc file1.md file2.md file3.md -o combined.pdf