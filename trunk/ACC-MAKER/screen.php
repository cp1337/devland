<?php 
/*
    Copyright (C) 2007 - 2008  Nicaw

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
include ("config.inc.php");
function detect()
    {
    $browser = array ("IE","OPERA","MOZILLA","NETSCAPE","FIREFOX","SAFARI");
    $os = array ("WIN","MAC");
    $info['browser'] = "OTHER";
    $info['os'] = "OTHER";
    foreach ($browser as $parent)
        {
        $s = strpos(strtoupper($_SERVER['HTTP_USER_AGENT']), $parent);
        $f = $s + strlen($parent);
        $version = substr($_SERVER['HTTP_USER_AGENT'], $f, 5);
        $version = preg_replace('/[^0-9,.]/','',$version);
        if ($s)
            {
            $info['browser'] = $parent;
            $info['version'] = $version;
            }
        }
    foreach ($os as $val)
        {
        if (eregi($val,strtoupper($_SERVER['HTTP_USER_AGENT']))) $info['os'] = $val;
        }
    return $info;
    } 

$d = detect();
$b = $d['browser'];
$v = $d['version'];
$o = $d['os'];

// real CSS starts here. im making it a variable so i can mess with it later :)
$CSS = file_get_contents('skins/'.$cfg['skin'].'.css');

//replace /*skindir*/ with images directory
$CSS = str_ireplace('/*$skindir*/',$cfg['skin_url'].$cfg['skin'].'/',$CSS);

header("Content-type: text/css");
//output for IE
if ($b=="IE" && ($v=="5.5" || $v=="6")){
//lets fix IE png background problems now.
$pattern="/background-image:\s+url\(['\"]?([^()'\"]*?\.png[^()'\"]*?)['\"]?\)\s*;/";
preg_match_all($pattern,$CSS,$out,PREG_PATTERN_ORDER);
$i=0;
while (isset($out[0][$i])){
	$fix= "filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src='".$out[1][$i]."', sizingMethod='image');";
	$CSS=str_replace($out[0][$i],$fix,$CSS);
	$i++;
}
//hacks for IE
//uncoment /*IE margin-right: -15px */
$pattern="/\/\*IE(.+?)\*\//";
preg_match_all($pattern, $CSS, $out, PREG_PATTERN_ORDER);
$CSS=str_replace($out[0], $out[1], $CSS);
echo $CSS;
}else{
//output for normal browsers
echo $CSS;
}
?>