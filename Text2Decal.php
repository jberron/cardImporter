<?php


function write_multiline_text($image, $font_size, $color, $font, $text, $start_x, $start_y, $max_width)
{
        $words = explode(" ", $text);
        $string = "";
        $tmp_string = "";
       
        for($i = 0; $i < count($words); $i++)
        {
            $tmp_string .= $words[$i]." ";
            $dim = imagettfbbox($font_size, 0, $font, $tmp_string);
            if($dim[4] < $max_width)
            {
                $string = $tmp_string;
            } else {
                $i--;
                $tmp_string = "";
                imagettftext($image, 11, 0, $start_x, $start_y, $color, $font, $string);
                $string = "";
                $start_y += 22;
            }
        }
                               
        imagettftext($image, 11, 0, $start_x, $start_y, $color, $font, $string); 

}
// setup
$fontpath= "./";
$font= checkRequest('font');
$textval= checkRequest('textval');
$size= checkRequest('size');
$padding= checkRequest('padding');
$bgcolor= checkRequest('bgcolor');
$textcolor= checkRequest('textcolor');
$transparent= checkRequest('transparent');


function checkRequest ($request)
{
    $return = isset($_REQUEST[$request]) ? $_REQUEST[$request] : null;
    return $return;
}


// defaults
if (empty($font)) {$font="arial.ttf";}
if (empty($textval)) $textval="Anita Lava La Tina  Anita Lava La Tina Anita Lava La Tina Anita Lava La Tina Anita Lava La Tina ";
if (empty($size)) $size= 22;
if (empty($padding)) $padding= 2;
if (empty($bgcolor))$bgcolor= "f0f0f0";
if (empty($textcolor)) $textcolor= "000000";
if (empty($transparent)) $transparent= 0;
if ($size>10) $antialias= 1;
else $antialias= 0;

$fontfile= $fontpath.$font;


$box = imageftbbox( $size, 0, $fontfile, $textval, array());
$boxwidth = $box[4];
$boxheight = abs($box[3]) + abs($box[5]);
$width = $boxwidth + ($padding*2) + 1;
$height = $boxheight + ($padding*2) + 0;
$textx = $padding;
$texty = ($boxheight - abs($box[3])) + $padding;

$png= imagecreate(500, 250);

// color
function mkcolor($color){

    global $png;
    $color = str_replace("#","",$color);
    $red = hexdec(substr($color,0,2));
    $green = hexdec(substr($color,2,2));
    $blue = hexdec(substr($color,4,2));
    $out = imagecolorallocate($png, $red, $green, $blue);
    return($out);
    }
$bg= mkcolor($bgcolor);
$tx= mkcolor($textcolor);

// transparency
if ($transparent==1) {
    $tbg= imagecolortransparent($png, $bg);
    }


if (!$antialias) {
    $tx= (0 - $tx);
    }


write_multiline_text($png, 22, $tx, $fontfile, $textval, 20, 20, 900);

header("content-type: image/png");
imagepng($png);

imagedestroy($png);