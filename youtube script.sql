/*
By Jackie Nguyen
github: https://github.com/aznone5
linkedin: https://www.linkedin.com/in/jackie-dan-nguyen/
Kaggle DataSet: https://www.kaggle.com/datasets/nelgiriyewithana/global-youtube-statistics-2023

TASK
Focus on aggerating data to find out estimates of whos making the most money out of the top youtube channels.
Find out what categorys perfrom the best, how many views each channel get or views each video get.
subscribers, country, and how many videos they put out, does that all play a part?
*/


/*
Create the table and use "Table data import Wizard" to import the date from a csv file
*/


use youtube;
drop table if exists youtube_statistics;
CREATE TABLE youtube_statistics (
Rank_stat int,
   Youtuber       varchar(255), -- Name of youtuber
   Subscribers      bigint, -- Number of subscribers
   Video_views bigint, -- Number of total views from the channel
   Category varchar(255), -- What category the channel is based off of
   Title varchar(255), -- Name of channel
   Uploads int, -- Number of uploaded videos
   Country varchar(255), -- Country of origin the youtuber or videos represent
   Abberviation Char(16), -- Country abbreviation
   Channel_type Varchar(255), -- Type of videos
   Video_views_rank bigint, -- Ranked based of most views
   Country_rank bigint, -- Ranked based of most subscribers in each country
   Channel_type_rank bigint, -- Ranked based of channel_type
   video_views_for_the_last_30_day bigint, -- Total views in last 30 days (since July 2023)
   lowest_monthly_earnings bigint, -- Lowest monthly earning since channel creation
   highest_monthly_earnings bigint, -- Highest monthly earnings since channel creation
   lowest_yearly_earnings bigint, -- Lowest yearly earnings since channel creation
   highest_yearly_earnings bigint, -- Highest yearly earnings since channel creation
   subscribers_for_last_30_days bigint, -- Subscriber increase/decrease in the last 30 days (since July 2023)
   created_year int, -- Year of channel creation
   created_month varchar(9), -- Month of channel creation (text)
   created_date int, -- Day of channel creation
   channel_date date, -- YYYY-MM-DD of channel creation
   month_in_numbers int -- Month of channel creation (numbers)
   
); 


/*
Let's see what were working with
*/


select *
from youtube_statistics;


/*
Dropping uneeded columns for visualizations
*/


alter table
youtube_statistics
drop column Abberviation,
drop column created_year,
drop column created_month,
drop column created_date,
drop column month_in_numbers;


/*
This category sums the total views from each category on youtube and 
how much profit a category makes on average, assuming on average someone
who makes 4000$ usd per 1 million views.
*/


select Category,  count(Category) as num_of_youtube_channels_of_each_category,
sum(video_views), round(0.004 * sum(video_views), 2) as Profit
from youtube_statistics
WHERE Category != 'UNKNOWN'
group by Category
order by num_of_youtube_channels_of_each_category desc;


/*
This tries too look into the subscriber count,
and to find a relation into how much an average subscriber looks at a youtube video, 
assuming 100% of subscribers look at that channel, it tends to range
around 10%-35% of subscibers/unsubscribers who look at each channel.
*/


select Youtuber, Subscribers, Video_views as Total_views,
round(Video_views / Subscribers, 2) as Average_views_per_subscriber
from youtube_statistics
where Video_views != 0
and Youtuber regexp '^[A-Za-z0-9[:space:]-]+$'
order by Subscribers desc
limit 20;


/*
Looking more indepth on yearly based earnings, we are seeing how the lowest,
highest, and on average a channels income results to throughout the active years.
## Note that ad revenue can vary based on the video length, how many ads can play on one video, 
if ads are skippable, duration of ad, type of ad, viewer is using adblock, etc. usually ranges between 
1,000$ to 10,000$ per 1 million views, so its not an accurate determination, as we use a
flate rate of 4,000$ per 1 million views.
*/


select s1.Youtuber, s1.lowest_yearly_earnings, s1.highest_yearly_earnings, s1.channel_date, round(s1.profit / s1.Channel_length_in_years, 2) as estimated_yearly_income
from
(select Youtuber, lowest_yearly_earnings, highest_yearly_earnings, channel_date, video_views,
round(0.004 * video_views, 2) as profit,  EXTRACT(YEAR FROM SYSDATE()) - EXTRACT(YEAR FROM channel_date) as Channel_length_in_years
from youtube_statistics
where lowest_yearly_earnings != 0
and Youtuber regexp '^[A-Za-z0-9[:space:]-]+$'


) as s1
where round(s1.profit / s1.Channel_length_in_years, 2) < s1.highest_yearly_earnings
limit 20;


/*
Looking more indepth on yearly based earnings, we are seeing how the lowest,
highest, and on average a channels income results to throughout the active years.
*/
 
 
select Country, count(Country) as Number_of_youtubers, sum(Uploads) as Number_of_uploads, sum(Subscribers) as Number_of_subscribers
from youtube_statistics
WHERE Country != 'UNKNOWN'
group by Country
order by Number_of_youtubers desc;


/*
A basic graph looking into more of just 
the number of uploads per category.
*/


select Category,  sum(Uploads) as Number_of_uploads 
from youtube_statistics
WHERE Category != 'UNKNOWN'
group by Category
order by Number_of_uploads desc;


/*
Looking more into the average views per video 
and the profit made from each video.
*/


select s.Youtuber, s.average_views_per_video, round(s.average_views_per_video * 0.004, 2) as profit_per_video,
s.video_views, s.uploads
from
(select Youtuber, round(video_views / Uploads, 0) as average_views_per_video, video_views, uploads
from youtube_statistics
) as s
where average_views_per_video is not null 
and average_views_per_video != 0
and Youtuber regexp '^[A-Za-z0-9[:space:]-]+$'
and s.uploads  >= 20
order by profit_per_video desc
limit 50;
