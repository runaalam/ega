//
//  Constants.swift
//  SwiftParseChat
//
//  Created by Runa Alam on 27/05/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

/* TODO: Try struct format for constants */
struct Constants {
    struct PF {
        struct Installation {
            static let ClassName = "_Installation"
        }
    }
}

//let HEXCOLOR(c) = [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

let DEFAULT_TAB							= 0

let MESSAGE_INVITE						= "Check out SwiftParseChat on GitHub: https://github.com/huyouare/SwiftParseChat"

let ONLY_ME                        = 1
let NETWORK                        = 2
let PUBLIC                         = 3
let GROUP                          = 4


/* Installation */
let PF_INSTALLATION_CLASS_NAME			= "_Installation"           //	Class name
let PF_INSTALLATION_OBJECTID			= "objectId"				//	String
let PF_INSTALLATION_USER				= "user"					//	Pointer to User Class

/* Groups */
let PF_GROUP_CLASS_NAME                = "Group"                    //	Class name
let PF_GROUP_OBJECTID                  = "objectId"                 //	String
let PF_GROUP_NAME                      = "groupName"                //	String

/* User */
let PF_USER_CLASS_NAME					= "_User"                   //	Class name
let PF_USER_OBJECTID					= "objectId"				//	String
let PF_USER_USERNAME					= "username"				//	String
let PF_USER_PASSWORD					= "password"				//	String
let PF_USER_EMAIL						= "email"                   //	String
let PF_USER_EMAILCOPY					= "emailCopy"               //	String
let PF_USER_FULLNAME					= "fullname"				//	String
let PF_USER_FULLNAME_LOWER				= "fullname_lower"          //	String
let PF_USER_FACEBOOKID					= "facebookId"              //	String
let PF_USER_PICTURE						= "picture"                 //	File
let PF_USER_THUMBNAIL					= "thumbnail"               //	File
let PF_USER_GENDER                      = "gender"                  //  String
let PF_USER_DOB                         = "dateOfBirth"             //  Date
let PF_USER_HEIGHT                      = "height"                  //  Number
let PF_USER_WEIGHT                      = "weight"                  //  Number
let PF_USER_GROUP                       = "group"                   //  Pointer to Group Class

/*post*/
let PF_POST_CLASS_NAME                  = "Post"                    //  Class name
let PF_POST_OBJECTID                    = "objectId"                //  String
let PF_POST_USER                        = "user"                    //  Pointer to user
let PF_POST_TITLE                       = "postTitle"               //  String
let PF_POST_DESCRITION                  = "postDescription"         //  String
let PF_POST_DATE                        = "postDate"                //  Date
let PF_POST_PRIVACY                     = "postPrivacy"             //  Number
let PF_POST_COMMENTS                    = "comments"                //  Pointer to comment

/*Post Commnets*/
let PF_COMMNET_CLASS_NAME               = "PostComment"             //  Class name
let PF_COMMENT_POST                     = "post"                    //  Pointer to post
let PF_COMMENT_USER                     = "user"                    //  Pointer to user
let PF_COMMENT_TEXT                     = "commentText"             //  String
let PF_COMMENT_DATE                     = "commentDate"             //  Date

/*User Network*/
let PF_NETWORK_CLASS_NAME				= "UserNetwork"             //	Class name
let PF_NETWORK_OBJECTID					= "objectId"				//	String
let PF_NETWORK_USER                     = "user"                    //  Pointer to user class
let PF_NETWORK_USER_GURDIAN             = "gurdian"                 //	Pointer to user class
let PF_NETWORK_USER_CHILD               = "child"                   //  pointer to user class


/* Activities */
let PF_ACTIVITY_CLASS_NAME              = "Activity"                //	Class name
let PF_ACTIVITY_OBJECTID				= "objectId"				//	String
let PF_ACTIVITY_NAME                    = "activityName"			//	String
let PF_ACTIVITY_MET_VALUE               = "metValue"                //	Number

/* User Activity */
let PF_USER_ACTIVITYLOG_CLASS_NAME      = "UserActivityLog"      //	Class name
let PF_USER_ACTIVITYLOG_OBJECTID        = "objectId"             // String
let PF_USER_ACTIVITYLOG_USER            = "user"                 //	Pointer to User Class
let PF_USER_ACTIVITYLOG_DATE            = "activityDate"         // Date
let PF_USER_ACTIVITYLOG_NAME            = "activityName"         //	String
let PF_USER_ACTIVITYLOG_DURATION        = "activityDuration"     //	Number
let PF_USER_ACTIVITYLOG_CALORIE_BURN    = "activityCaloriBurn"   //	Number
let PF_USER_ACTIVITYLOG_NOTE            = "activityNote"         //	String

/*Medication Log */
let PF_MEDICATION_LOG_CLASS_NAME        = "UserMedicationLog"       // Class name
let PF_Medication_LOG_USER              = "user"                    // Pointer to user class
let PF_Medication_LOG_DATE              = "medicationLogDate"       // Date
let PF_Medication_LOG_TAKEN_STRING      = "takenMedicationString"   // String type Array
let PF_Medication_LOG_TAKEN_VALUE       = "takenMedicationValue"    // Bool type Array

/* User Medication List*/
let PF_MEDICATION_CLASS_NAME            = "UserMedication"           // Class name
let PF_MEDICATION_USER                  = "user"                     // Pointer to User Class
let PF_MEDICATION_NAME                  = "medicationName"           //	String
let PF_MEDICATION_DESCRITION            = "medicationDescription"    //	String
let PF_MEDICATION_DOSE                  = "dose"                     //	String
let PF_MEDICATION_REGULER               = "regulerMedication"        // Boolean
let PF_MEDICATION_START_DATE            = "startDate"                // Date
let PF_MEDICATION_END_DATE              = "endDate"                  // Date
let PF_MEDICATION_TIME                  = "time"                     // Date type Array
let PF_MEDICATION_REMINDER              = "medicationReminder"       // Boolean
let PF_MEDICATION_NOTE                  = "medicationNote"           // String

/* User Meal List */
let PF_MEALLIST_CLASS_NAME              = "UserMealList"             // Class name
let PF_MEALLIST_USER                    = "user"                     // Pointer to User Class
let PF_MEALLIST_OBJECTID                = "objectId"                 // String
let PF_MEALLIST_MEAL_TYPE               = "mealType"                 // String
let PF_MEALLIST_MEAL_NAME               = "mealName"                 // String
let PF_MEALLIST_MEAL_SERVING_SIZE       = "mealSize"                 // String
let PF_MEALLIST_MEAL_KILOJOULS          = "mealKilojouls"            // Number

/* User DietDiary */
let PF_DIETDIARY_CLASS_NAME             = "UserDietDiary"            // Class name
let PF_DIETDIARY_USER                   = "user"                     // Pointer to User Class
let PF_DIETDIARY_DATE                   = "dietDate"                 // Date
let PF_DIETDIARY_OBJECTID               = "objectId"                 // String
let PF_DIETDIARY_TOTAL_CONSUMED         = "totalConsumed"            // String
let PF_DIETDIARY_BREAKFAST_ITEMS        = "breakfastItems"           // String type Array
let PF_DIETDIARY_BREAKFAST_CONSUMED     = "breakfastConsumed"        // Number
let PF_DIETDIARY_LUNCH_ITEMS            = "lunchItems"               // String type Array
let PF_DIETDIARY_LUNCH_CONSUMED         = "lunchConsumed"            // Number
let PF_DIETDIARY_DINNER_ITEMS           = "dinnerItems"              // String type Array
let PF_DIETDIARY_DINNER_CONSUMED        = "dinnerConsumed"           // Number
let PF_DIETDIARY_SNACK_ITEMS            = "snackItems"               // String type Array
let PF_DIETDIARY_SNACK_CONSUMED         = "snackConsumed"            // Number

/* Chat */
let PF_CHAT_CLASS_NAME					= "Chat"					//	Class name
let PF_CHAT_USER						= "user"					//	Pointer to User Class
let PF_CHAT_GROUPID						= "groupId"                 //	String
let PF_CHAT_TEXT						= "text"					//	String
let PF_CHAT_PICTURE						= "picture"                 //	File
let PF_CHAT_VIDEO						= "video"                   //	File
let PF_CHAT_CREATEDAT					= "createdAt"               //	Date

/* Messages*/
let PF_MESSAGES_CLASS_NAME				= "Messages"				//	Class name
let PF_MESSAGES_USER					= "user"					//	Pointer to User Class
let PF_MESSAGES_GROUPID					= "groupId"                 //	String
let PF_MESSAGES_DESCRIPTION				= "description"             //	String
let PF_MESSAGES_LASTUSER				= "lastUser"				//	Pointer to User Class
let PF_MESSAGES_LASTMESSAGE				= "lastMessage"             //	String
let PF_MESSAGES_COUNTER					= "counter"                 //	Number
let PF_MESSAGES_UPDATEDACTION			= "updatedAction"           //	Date

/* Notification */
let NOTIFICATION_APP_STARTED			= "NCAppStarted"
let NOTIFICATION_USER_LOGGED_IN			= "NCUserLoggedIn"
let NOTIFICATION_USER_LOGGED_OUT		= "NCUserLoggedOut"