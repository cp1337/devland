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
if ($guild->getAttr('owner_acc') != $_SESSION['account']) die('Not your guild');
//retrieve post data
$form = new Form('invite');
//check if any data was submited
if ($form->exists()){
	if ($guild->countInvited() <= 20){
		$form->attrs['rank'] = ucfirst($form->attrs['rank']);
		if (AAC::ValidGuildRank($form->attrs['rank'])){
			$player = new Player();
			if ($player->find($form->attrs['player'])){
				if ($guild->memberInvite($player->getAttr('id'), $form->attrs['rank'])){
					$guild->save();
					//success
					$msg = new IOBox('message');
					$msg->addMsg($player->getAttr('name').' was invited to your guild');
					$msg->addClose('OK');
					$msg->show();
				}else $error = 'Cannot invite player';
			}else $error = 'Cannot find this player';
		}else $error = 'Not a valid name for rank';
	}else $error = 'You are not allowed to invite more players.<br/>Remove old invites first.';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addClose('OK');
		$msg->show();
	}
}else{
	//create new form
	$form = new IOBox('invite');
	$form->target = $_SERVER['PHP_SELF'].'?guild_id='.(int)$_REQUEST['guild_id'];
	$form->addLabel('Invite Member');
	$form->addMsg('Enter the name and rank of player you want to invite');
	$form->addInput('player');
	$form->addInput('rank');
	$form->addClose('Cancel');
	$form->addSubmit('Next >>');
	$form->show();
}
?>