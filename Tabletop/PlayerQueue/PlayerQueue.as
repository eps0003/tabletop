class PlayerQueue
{
	private CPlayer@[] players;

	bool opEquals(const PlayerQueue&in queue)
	{
		return players == queue.players;
	}

	void Add(CPlayer@ player)
	{
		if (!contains(player))
		{
			players.push_back(player);
		}
	}

	void Remove(CPlayer@ player)
	{
		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ otherPlayer = players[i];
			if (player is otherPlayer)
			{
				players.removeAt(i);
				break;
			}
		}
	}

	CPlayer@ remove()
	{
		if (players.empty())
		{
			return null;
		}

		CPlayer@ player = players[0];
		players.removeAt(0);
		return player;
	}

	CPlayer@[] remove(uint count)
	{
		CPlayer@[] removedPlayers;

		for (uint i = 0; i < count && players.size() > 0; i++)
		{
			removedPlayers.push_back(players[0]);
			players.removeAt(0);
		}

		return removedPlayers;
	}

	bool contains(CPlayer@ player)
	{
		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ otherPlayer = players[i];
			if (player is otherPlayer)
			{
				return true;
			}
		}
		return false;
	}

	CPlayer@ peekPlayer()
	{
		return players.empty() ? null : players[0];
	}

	void Clear()
	{
		players.clear();
	}

	bool isEmpty()
	{
		return players.empty();
	}

	uint size()
	{
		return players.size();
	}

	CPlayer@[] toArray()
	{
		return players;
	}
}

namespace PlayerQueue
{
	PlayerQueue@ get()
	{
		PlayerQueue@ queue;
		if (!getRules().get("queue", @queue))
		{
			@queue = PlayerQueue();
			getRules().set("queue", @queue);
		}
		return queue;
	}
}
