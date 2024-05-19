#include "RenderState.as"

class ParallelState : RenderState
{
	private RenderState@[] states;
	private bool[] complete;

	ParallelState(RenderState@[] states)
	{
		this.states = states;
		complete = array<bool>(states.size(), false);
	}

	void Start()
	{
		for (uint i = 0; i < states.size(); i++)
		{
			states[i].Start();
		}
	}

	void Update()
	{
		for (uint i = 0; i < states.size(); i++)
		{
			RenderState@ state = states[i];

			if (!state.isComplete())
			{
				state.Update();
			}
			else if (!complete[i])
			{
				complete[i] = true;
				state.End();
			}
		}
	}

	bool isComplete()
	{
		for (uint i = 0; i < complete.size(); i++)
		{
			if (!complete[i])
			{
				return false;
			}
		}

		return true;
	}
}
