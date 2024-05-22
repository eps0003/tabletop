#include "RenderState.as"

class PlayerLeave : RenderState
{
	private Game@ game;

	private string player;
	private u16[] hand;

	private dictionary@ renderCards;
	private RenderCard@[] handRenderCards;
	private RenderCard[] renderCardsStart;

	private uint gameTime = 0.0f;

	private float time
	{
		get const
		{
			if (gameTime == 0.0f)
			{
				return 0.0f;
			}

			float duration = getTicksASecond() * 0.4f; // 1 second
			float t = Maths::Clamp01((getGameTime() - gameTime) / duration);
			return 1 - Maths::Pow(1 - t, 2); // Ease out
		}
	}

	PlayerLeave(Game@ game, dictionary@ renderCards, string player)
	{
		@this.game = game;
		@this.renderCards = renderCards;
		this.player = player;
	}

	void Start()
	{
		// Get the player's hand
		game.getHand(player, hand);

		// Remove the player and forfeit their hand
		game.RemovePlayer(player);

		// For all the cards in the hand
		for (uint i = 0; i < hand.size(); i++)
		{
			u16 card = Card::clean(hand[i]);

			// Get the rendered card
			RenderCard@ renderCard;
			renderCards.get("" + card, @renderCard);

			handRenderCards.push_back(renderCard);

			// Copy the current state of the rendered card
			renderCardsStart.push_back(renderCard);

			// Hide the rendered card during the animation
			renderCard.Hide();
		}

		// Store the current game time
		gameTime = getGameTime();
	}

	void Render()
	{
		for (uint i = 0; i < handRenderCards.size(); i++)
		{
			RenderCard renderCardStart = renderCardsStart[i];
			RenderCard@ renderCard = handRenderCards[i];

			Vec2f position = Vec2f_lerp(renderCardStart.getPosition(), renderCard.getPosition(), time);
			float angle = renderCard.getAngle(); // TODO
			float scale = Maths::Lerp(renderCardStart.getScale(), renderCard.getScale(), time);

			DrawCard(hand[i], position, angle, scale);
		}
	}

	void End()
	{
		for (uint i = 0; i < handRenderCards.size(); i++)
		{
			handRenderCards[i].Show();
		}
	}

	bool isComplete()
	{
		return time >= 1.0f;
	}
}
