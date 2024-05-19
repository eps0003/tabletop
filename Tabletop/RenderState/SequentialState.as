#include "RenderState.as"

class SequentialState : RenderState
{
	private RenderState@[] states;
	private bool[] started;
	private uint index = 0;

	SequentialState(RenderState@[] states)
	{
		this.states = states;
		started = array<bool>(states.size(), false);
	}

	SequentialState@ Add(RenderState@ state)
	{
		states.push_back(state);
		started.push_back(false);
		return this;
	}

	void Update()
	{
		if (isComplete()) return;

		RenderState@ state = states[index];

		if (!started[index])
		{
			started[index] = true;
			state.Start();
		}

		state.Update();

		if (state.isComplete())
		{
			state.End();
			index++;

			if (!isComplete())
			{
				states[index].Start();
			}
		}
	}

	bool isComplete()
	{
		return index >= states.size();
	}
}
