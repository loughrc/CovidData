## Covid Data Exploration

### Introduction:
This is a MySQL focused data exploration task involving the exploration of worldwide data relating to covid-19 in terms of cases, deaths and vaccinations. We also carry out some visualisation in Tableau to complement this work. A further analysis of the data is being done using pandas, though this part of the project is still a work in progress.

### The Data:
The data was retrieved from https://ourworldindata.org/covid-deaths. It contains a large number of features pertaining to the spread of covid-19 in all countries of the world from February 2020 to the present day. The data is updated daily, though at the time of this project the last complete month's worth of data was April 2021. The features of the dataset include the daily number of cases, deaths, vaccinations, people who are fully vaccinated (i.e. two doses), as well as some aggregate columns like vaccinations per hundred thousand, cases per million, deaths per million etc on a rolling basis (i.e. a new row of updated figures daily per country). MySQL is used to dive into this data in more detail.

### Project Overview:
The original data file was split into two separate csv files using Microsoft Excel, and each was loaded into MySQL as separate tables; one contains features related to covid vaccinations, and the other contains features related to covid deaths. A number of different techniques, such as the use of aggregate functions, temp tables and window functions are used to extract and explore data from both tables at the same time.

Certain queries were made with Tableau visualisation in mind, and so four visualisations of this data were then created in Tableau Public. These consist of some of the figures derived from the exploration of the data using MySQL, and can be seen in this dashboard: https://public.tableau.com/profile/conor.loughran#!/vizhome/Covid_Information_Worldwide/Dashboard1. 

### Motivation:
The motivation for this task was to show how MySQL can be used as a data exploration tool for data that does not require any preprocessing, and that we can use Tableau to display data without having to use Python. Python pandas is excellent for manipulating data in a way that makes it easier to explore, but it is not always required, especially not when the data is of high quality.

### Technologies Used:
Microsoft Office Excel, MySQL, Tableau Public.

### Summary:

- Retrieved data from https://ourworldindata.org/covid-deaths.
- Split data into two tables in order to carry out a comprehensive exploration using MySQL
- Explored data using a number of different types of MySQL operations (aggregate functions, joins, temp tables etc.)
- Made some visualisations of this data on Tableau Public (https://public.tableau.com/profile/conor.loughran#!/vizhome/Covid_Information_Worldwide/Dashboard1)
- Deeper data exploration using pandas (In Progress)
