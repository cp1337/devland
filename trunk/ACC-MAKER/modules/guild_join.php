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
include ("../include.inc.php");
//load account if loged in
$account = new Account();
($account->load($_SESSION['account'])) or die('You need to login first. '.$account->getError());
//load guild
$guild = new Guild();
if (!$guild->load($_REQUEST['guild_id'])) throw new Exception('Unable to load guild.');
//retrieve post data
$form = new Form('join');
//check if any data was submited
if ($form->exists()){
	$player = new Player();
	if ($player->load($form->attrs['player']) && $player->getAttr('account') == $_SESSION['account']){
		if (!$player->isAttr('guild_id')){
			if ($guild->memberJoin($player->getAttr('id'), 1)){
				$guild->save();
				//success
				$msg = new IOBox('message');
				$msg->addMsg('You have joined '.htmlspecialchars($guild->getAttr('name')));
				$msg->addClose('OK');
				$msg->show();
			}else $error = 'Cannot join guild';
		}else $error = 'You already belong to guild. Leave "'.htmlspecialchars($player->getAttr('guild_name')).'" first.';
	}else $error = 'Cannot load player';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addClose('OK');
		$msg->show();
	}
}else{
	//make a list of invited characters
	foreach ($account->players as $player)
		if ($guild->isInvited($player['id']))
			$list[$player['id']] = $player['name'];
	if (!isset($list)) die();

	//create new form
	$form = new IOBox('join');
	$form->target = $_SERVER['PHP_SELF'].'?guild_id='.urlencode($_REQUEST['guild_id']);
	$form->addLabel('Join Guild');
	$form->addMsg('Select the character to join');
	$form->addSelect('player', $list);
	$form->addClose('Cancel');
	$form->addSubmit('Next >>');
	$form->show();
}
?>