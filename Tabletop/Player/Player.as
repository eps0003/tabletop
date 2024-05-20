class Player
{
	private u16 id;
	private string username;
	private string nickname;

	Player(CPlayer@ player)
	{
		id = player.getNetworkID();
		username = player.getUsername();
		nickname = player.getCharacterName();
	}

	Player(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;

		CPlayer@ player = getPlayer();
		if (player is null)
		{
			warn("Deserialized player is null: " + id);
			return;
		}

		username = player.getUsername();
		nickname = player.getCharacterName();
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	u16 getId()
	{
		return id;
	}

	string getUsername()
	{
		return username;
	}

	string getNickname()
	{
		CPlayer@ player = getPlayer();
		if (player !is null)
		{
			nickname = player.getCharacterName();
		}
		return nickname;
	}

	CPlayer@ getCPlayer()
	{
		return getPlayerByNetworkId(networkId);
	}
}
