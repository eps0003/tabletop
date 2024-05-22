#include "RenderState.as"

class SequentialState : RenderState
{
	private RenderState@[] states;
	private bool started = false;

	SequentialState(RenderState@[] states)
	{
		this.states = states;
	}

	SequentialState@ Add(RenderState@ state)
	{
		states.push_back(state);
		return this;
	}

	void Render()
	{
		if (isComplete()) return;

		RenderState@ state = states[0];

		// Start state
		if (!started)
		{
			state.Start();

			// Immediately end state
			if (state.isComplete())
			{
				state.End();
				states.removeAt(0);

				// Process the next state this frame
				Render();
				return;
			}

			started = true;
		}

		state.Render();

		// End state
		if (state.isComplete())
		{
			state.End();
			states.removeAt(0);
			started = false;

			// Process the next state this frame
			Render();
		}
	}

	bool isComplete()
	{
		return states.empty();
	}
}
