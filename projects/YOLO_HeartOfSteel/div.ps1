# clear
rm ./dataset -Recurse -Force -ErrorAction SilentlyContinue

# create folders
mkdir './datasets/images/train' -Force | Out-Null
mkdir './datasets/images/val' -Force | Out-Null
mkdir './datasets/labels/train' -Force | Out-Null
mkdir './datasets/labels/val' -Force | Out-Null
mkdir './tmp' -Force | Out-Null

$classes = @(
	'crazing',
	'inclusion',
	'patches',
	'pitted_surface',
	'rolled-in_scale',
	'scratches'
)
foreach ($c in $classes) {
	# labels
	$labelsAll = gci './NEU-DET (1)/ANNOTATIONS' -Filter "${c}_*"  # get files by perfix
	$labelsAll | ForEach-Object {
		$xml = [xml](cat $_.FullName) # read as xml
		$lines = @()

		# image size
		$width = [double]($xml.annotation.size.width)
		$height = [double]($xml.annotation.size.height)

		# boxes
		$boxes = $xml.annotation.object
		$boxes | ForEach-Object {
			$class = $classes.IndexOf($_.name)
			$box = $_.bndbox
			$xmax = [double]($box.xmax)
			$xmin = [double]($box.xmin)
			$ymax = [double]($box.ymax)
			$ymin = [double]($box.ymin)

			$xCenter = (($xmin + $xmax) / 2.0) / $width
			$yCenter = (($ymin + $ymax) / 2.0) / $height
			$w = $($xmax - $xmin) / $width
			$h = $($ymax - $ymin) / $height

			$line = "$class $xCenter $yCenter $w $h"
			$lines = $lines + $line
		}
		$lines | Out-File -Encoding ascii -FilePath "./tmp/$($_.Name -replace 'xml$', 'txt')"
	}
	$labelsAll = gci ./tmp -Filter "${c}_*"
	$labelsVal = $labelsAll | Get-Random -Count 60  # 300 * 20% = 60
	$labelsTrain = $labelsAll | Where-Object {$_ -notin $labelsVal}  # remove val files

	$labelsTrain | cp -Destination ./datasets/labels/train
	$labelsVal | cp -Destination ./datasets/labels/val

	# images
	$imagesTrain = $labelsTrain | %{gi "./NEU-DET (1)/IMAGES/$($_.Name -replace 'txt$', 'jpg')"}
	$imagesVal = $labelsVal | %{gi "./NEU-DET (1)/IMAGES/$($_.Name -replace 'txt$', 'jpg')"}

	$imagesTrain | cp -Destination ./datasets/images/train
	$imagesVal | cp -Destination ./datasets/images/val
}

# clear
rm ./tmp -Recurse -Force -ErrorAction SilentlyContinue

