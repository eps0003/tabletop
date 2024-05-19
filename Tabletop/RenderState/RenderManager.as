#include "RenderState.as"
#include "SequentialState.as"

class RenderManager
{
	private SequentialState states;

	RenderManager()
	{
		// states.Start();
	}

	RenderManager@ Add(RenderState@ state)
	{
		states.Add(state);
		return this;
	}

	void Update()
	{
		if (!states.isComplete())
		{
			states.Update();

			if (states.isComplete())
			{
				states.End();
			}
		}
	}
}
