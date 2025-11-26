$files = dir -Path '../notes' -File | Sort-Object {
	[int]($_.BaseName -split '_')[0]    
}
pandoc $files.FullName -o note.pdf --toc --pdf-engine=xelatex -V CJKmainfont='Microsoft YaHei'
