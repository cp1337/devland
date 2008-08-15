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
class Account extends SQL
{
private $attrs;
public $players;

public function __construct()
	{
		parent::__construct();
	}

public function load($id)
	{
		if (!is_numeric($id)) return false;
		//load attributes from database
		$acc = $this->myRetrieve('accounts', array('id' => $id));
		$nicaw_acc = $this->myRetrieve('nicaw_accounts', array('account_id' => $id));
		if ($acc === false){
			if ($this->exists())
				throw new Exception('Cannot load existing account:<br/>'.$this->getError());
			return false;
		}
		//arranging attributes, ones on the left will be used all over the aac
		$this->attrs['accno'] = (int) $acc['id'];
		$this->attrs['password'] = (string) $acc['password'];
		$this->attrs['email'] = (string) $acc['email'];
		$this->attrs['rlname'] = $nicaw_acc['rlname'];
		$this->attrs['location'] = $nicaw_acc['location'];
		$this->attrs['comment'] = $nicaw_acc['comment'];
		$this->attrs['recovery_key'] = $nicaw_acc['recovery_key'];
		if ($acc['premdays'] > 0) $this->attrs['premend'] = $acc['premdays']*24*3600 + time();
		elseif ($acc['premEnd'] > 0) $this->attrs['premend'] = $acc['premEnd'];
		//get characters of this account
		$this->myQuery('SELECT players.id, players.name FROM players WHERE (`account_id`='.$this->quote($this->attrs['accno']).')');
		if ($this->failed()) throw new Exception($this->getError());
		while ($a = $this->fetch_array()){
			$this->players[] = array('name' => $a['name'], 'id' => $a['id']);
		}
		//good, now we have all attributes stored in object
		return true;
	}

public function save()
	{
		$acc['id'] = $this->attrs['accno'];
		$acc['password'] = $this->attrs['password'];
		$acc['email'] = $this->attrs['email'];
		$nicaw_acc['account_id'] = $this->attrs['accno'];
		$nicaw_acc['rlname'] = $this->attrs['rlname'];
		$nicaw_acc['location'] = $this->attrs['location'];
		$nicaw_acc['comment'] = $this->attrs['comment'];
		$nicaw_acc['recovery_key'] = $this->attrs['recovery_key'];
		
		if (!$this->myReplace('nicaw_accounts',$nicaw_acc))
			throw new Exception('Cannot save account:<br/>'.$this->getError());

		if ($this->exists()){
			if (!$this->myUpdate('accounts',$acc, array('id' => $this->attrs['accno'])))
				throw new Exception('Cannot save account:<br/>'.$this->getError());
		}else{
			if (!$this->myInsert('accounts',$acc))
				throw new Exception('Cannot save account:<br/>'.$this->getError());
		}
		return true;
	}

public function getAttr($attr)
	{
		return $this->attrs[$attr];
	}

public function setAttr($attr,$value)
	{
		$this->attrs[$attr] = $value;
	}

public function setPassword($new)
	{global $cfg;
		$new = $new.$cfg['password_salt'];
		if ($cfg['password_type'] == 'md5')
			$new = md5($new);
		elseif ($cfg['password_type'] == 'sha1')
			$new = sha1($new);
		if (empty($new)) throw new Exception('Empty password is not allowed.');
		$this->attrs['password'] = $new;
	}

public function checkPassword($pass)
	{global $cfg;
		$pass = $pass.$cfg['password_salt'];
		if ($cfg['password_type'] == 'md5'){
			$pass = md5($pass);
		}elseif ($cfg['password_type'] == 'sha1'){
			$pass = sha1($pass);
		}elseif ($cfg['password_type'] == 'plain'){
		}else throw new Exception('Unknow password encoding.');
		return $this->attrs['password'] == (string)$pass && !empty($pass);
	}

public function exists()
	{
		$this->myQuery('SELECT * FROM `accounts` WHERE `id` = '.$this->quote($this->attrs['accno']));
		if ($this->failed()) throw new Exception('Account::exists() cannot determine whether account exists');
		if ($this->num_rows() > 0) return true;
		return false;
	}

public function logAction($action)
	{
		$this->myQuery('INSERT INTO `nicaw_account_logs` (id, ip, account_id, date, action) VALUES(NULL, INET_ATON('.$this->quote($_SERVER['REMOTE_ADDR']).'), '.$this->quote($this->attrs['accno']).', UNIX_TIMESTAMP(NOW()), '.$this->quote($action).')');
		if ($this->failed())
			throw new Exception($this->getError());
	}
	
public function removeRecoveryKey()
	{
		$this->attrs['recovery_key'] = NULL;
	}

public function addRecoveryKey()
	{
		$this->attrs['recovery_key'] = substr(str_shuffle(md5(mt_rand()).md5(time())), 0, 32);
		$this->logAction('Recovery key added');
		return $this->attrs['recovery_key'];
	}

public function checkRecoveryKey($key)
	{
		return $this->attrs['recovery_key'] === $key && !empty($key);
	}

public function vote($option)
	{
		$this->myQuery('INSERT INTO `nicaw_poll_votes` (option_id, ip, account_id) VALUES('.$this->quote($option).', INET_ATON('.$this->quote($_SERVER['REMOTE_ADDR']).'), '.$this->quote($this->attrs['accno']).')');
		if ($this->failed())
			throw new Exception($this->getError());
	}
	
public function getMaxLevel()
	{
		$this->myQuery('SELECT MAX(level) AS maxlevel FROM `players` WHERE `account_id` = '.$this->quote($this->attrs['accno']));
		if ($this->failed())
			throw new Exception($this->getError);
		$row = $this->fetch_array();
		return (int) $row['maxlevel'];
	}

public function canVote($option)
	{
		$query = 'SELECT nicaw_polls.id FROM nicaw_polls, nicaw_poll_options
WHERE nicaw_polls.id = nicaw_poll_options.poll_id
AND nicaw_poll_options.id = '.$this->quote($option).'
AND '.$this->quote($this->getMaxLevel()).' > minlevel
AND nicaw_polls.startdate < UNIX_TIMESTAMP(NOW())
AND nicaw_polls.enddate > UNIX_TIMESTAMP(NOW())';
		$this->myQuery($query);
		if ($this->failed())
			throw new Exception($this->getError);
		if ($this->num_rows() == 0) return false;
		if ($this->num_rows() > 1) throw new Exception('Unexpected SQL answer.');
		$a = $this->fetch_array();
		$poll_id = $a['id'];
		$query = 'SELECT * FROM nicaw_poll_votes, nicaw_poll_options
WHERE nicaw_poll_options.poll_id = '.$this->quote($poll_id).'
AND nicaw_poll_options.id = nicaw_poll_votes.option_id
AND (account_id = '.$this->quote($this->attrs['accno']).' OR ip = INET_ATON('.$this->quote($_SERVER['REMOTE_ADDR']).')
)';
		$this->myQuery($query);
		if ($this->failed())
			throw new Exception($this->getError);
		if ($this->num_rows() == 0) return true;
		elseif ($this->num_rows() == 1) return false;
		else throw new Exception('Unexpected SQL answer.');
	}
}
?>