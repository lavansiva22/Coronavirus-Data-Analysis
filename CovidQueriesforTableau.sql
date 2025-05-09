/*

Queries used for Tableau Project

*/


-- 1. 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidProject.CovidDeaths
where continent <> ''
order by 1,2


-- 2. 

Select location, SUM(new_deaths) as TotalDeathCount
From CovidProject.CovidDeaths
Where continent = ''
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject.CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


