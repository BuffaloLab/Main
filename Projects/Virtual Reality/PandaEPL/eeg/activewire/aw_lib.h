/*

	Copyright (C) 2006  Dave Keck

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

*/

#ifdef __cplusplus

extern "C"
{

#endif

#include <stdbool.h>
#include <time.h>

/* Event stuff */

enum event_types
{

	AW_EVENT_BOARD_CONNECTED = 1,
	AW_EVENT_BOARD_DISCONNECTED,
	AW_EVENT_BOARD_DATA_CHANGED

};

typedef unsigned char AW_EVENT_TYPE;

/* aw_event structure is aligned and size is divisible by 4;
   should be portable, to both 32- and 64-bit machines. */

typedef struct aw_event
{

	struct timespec timestamp;	/* The time the event occurred. */
	unsigned char boardNumber;	/* Board that the event applies to. */
	unsigned char boardData[2];	/* A two-byte array containing the board's state when the event occurred. */
	AW_EVENT_TYPE eventType;	/* Event type; see event_types above. */

} aw_event, * AW_EVENT;

/* aw_event_list structure is aligned and and padded
   so size is divisible by 4; should be portable to
   both 32- and 64-bit machines. */

typedef struct aw_event_list
{

	AW_EVENT *events;
	unsigned short numberOfEvents;
	
	unsigned char pad[2];

} aw_event_list, * AW_EVENT_LIST;

/* Event delivery methods */

enum aw_delivery_methods
{

	AW_EVENT_DELIV_NONE = 0,		/* Disregard all events. */
	AW_EVENT_DELIV_CALLBACK,		/* Deliver events immediatley via the three callbacks. */
	AW_EVENT_DELIV_BUFFER			/* Buffer events until they're acquired using aw_getEvents. */

};

typedef unsigned char AW_EVENT_DELIV_METHOD;

/* Define the possible errors, which hopefully never see the light of day. */

enum aw_err
{

	AW_ERR_NONE = 0,		/* No error */
	AW_ERR_NOT_INIT,		/* Not initialized */
	AW_ERR_ALREADY_INIT,	/* Already initialized */
	AW_ERR_INTERNAL,		/* Internal error */
	AW_ERR_LOCAL_SOCKET,	/* Unable to create socket to interface with server */
	AW_ERR_CONTACT_SERV,	/* Unable to contact server */
	AW_ERR_AUTH,			/* Unable to authorize client, password is probably incorrect */
	AW_ERR_ENCRYPT,			/* Unable to encrypt password for transit to server */
	AW_ERR_LEN_NOT_DIV_2	/* Length is not divisible by two. */

};

typedef unsigned char AW_ERR;

/* Callback Typedefs */

typedef void (*BoardConnectedCallback)		(AW_EVENT event);
typedef void (*BoardDisconnectedCallback)	(AW_EVENT event);
typedef void (*BoardDataChangedCallback)	(AW_EVENT event);

/* Functions */

AW_ERR aw_init();
AW_ERR aw_initWithAddress(char *address, char *password);

void aw_close();

AW_ERR aw_setDirectionsOfPinSets(unsigned char boardNumber,
								 unsigned char firstPinSetDirections,
								 unsigned char secondPinSetDirections);

AW_ERR aw_readData(unsigned char boardNumber, unsigned char *buffer, unsigned short length);

AW_ERR aw_writeData(unsigned char boardNumber, unsigned char *data, unsigned short length);

AW_ERR aw_setEventDeliveryMethod(AW_EVENT_DELIV_METHOD newDeliveryMethod,
								 BoardConnectedCallback newBoardConnectedCallback,	/* Callbacks only used when deliveryMethod == AW_DELIV_CALLBACK */
								 BoardDisconnectedCallback newBoardDisconnectedCallback,
								 BoardDataChangedCallback newBoardDataChangedCallback,
								 unsigned short newMaxEvents);	/* maxEvents is only used when deliveryMethod == AW_DELIV_BUFFER. */

AW_EVENT_LIST aw_getEvents();
void aw_clearEvents();

AW_ERR aw_numberOfConnectedBoards(unsigned char *numberOfBoards);

void aw_decimalToBinary(unsigned char *decimalArray, unsigned short arrayLength, unsigned char *binaryArray);
void aw_binaryToDecimal(unsigned char *binaryArray, unsigned short arrayLength, unsigned char *decimalArray);

#ifdef __cplusplus

}

#endif
