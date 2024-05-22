class LerpTimer
{
	private uint gameTime = 0;
	private float duration = 0.0f;

	LerpTimer(float seconds)
	{
		duration = getTicksASecond() * seconds;
	}

	void Start()
	{
		gameTime = getGameTime();
	}

	float getTime()
	{
		if (gameTime == 0)
		{
			return 0.0f;
		}

		if (duration == 0.0f)
		{
			return 1.0f;
		}

		return Maths::Clamp01((getGameTime() - gameTime) / duration);
	}

	bool isComplete()
	{
		return getTime() >= 1.0f;
	}
}
