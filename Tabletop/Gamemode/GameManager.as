namespace Game
{
	string getScript()
	{
		return getRules().get_string("game_script");
	}

	void SetScript(string script)
	{
		getRules().set_string("game_script", script);
	}
}
