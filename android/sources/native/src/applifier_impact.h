/*
 * Applifier Impact Native SDK
 *
 * (c) Applifier 2013
 */

#ifdef __cplusplus
extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif

// Event ID's
const int EVENT_IMPACT_CLOSE = 1;
const int EVENT_IMPACT_OPEN = 2;
const int EVENT_IMPACT_VIDEO_START = 3;
const int EVENT_IMPACT_VIDEO_COMPLETE = 4;
const int EVENT_IMPACT_CAMPAIGNS_AVAILABLE = 5;
const int EVENT_IMPACT_CAMPAIGNS_FAILED = 6;	

// Options
const int OPTION_IMPACT_SHOW_OFFERSCREEN = 0;
const int OPTION_IMPACT_HIDE_OFFERSCREEN = 1;
const int OPTION_IMPACT_SHOW_ANIMATED = 1;
const int OPTION_IMPACT_SHOW_STATIC = 0;

// Reward struct
typedef struct impact_reward_item {
	const char* reward_name;
	const char* reward_image_url;
} impact_reward_item;

// *===========* Impact method *===========*

/* The event listener */
void (*impact_event_callback)(int, const char*);

/**
 * Initialize impact with the given game ID
 */
void applifier_impact_init(int game_id, void (*iec)(int, const char*));

/**
 * Show Impact
 */
void applifier_impact_show(int show_offerscreen, int show_animated);

/**
 * Get the reward items configured
 */
impact_reward_item* applifier_impact_get_reward_items();

/**
 * Set the reward item
 */
void applifier_impact_set_reward_item(const char* key);

void applifier_impact_debug(const char* msg);

#ifdef __cplusplus
}
#endif	