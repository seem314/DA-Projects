Select *
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

select Location, date, total_cases,new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2


-- Total cases vs Total deaths 
-- showing the likiyhood of death from Covied based on location 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from Portfolio_Project..CovidDeaths
where continent is not null 
order by 1,2 desc

--Total Case vs population
-- Showing the percentage of population who contracted Covied 

select Location, date,  population,total_cases, (total_cases/ population)*100 PrecentOfPopulationInfected
from Portfolio_Project..CovidDeaths
where continent is not null
--where location like '%phili%'
order by 1,2 

-- Countries Highest Infaction Rate compare to population

select Location, Max(total_cases) HighestInfactionRate , Max((total_cases/population))*100 as PrecentOfPopulationInfected
from Portfolio_Project..CovidDeaths
where continent is not null
Group by population, location
order by PrecentOfPopulationInfected desc

-- Countries with the highest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAK DOWN BY CONTINENT

--showing continents with the highest death per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--glopal precentage 

Select  SUM(population),SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) TotalDeath,SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPrecentage
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2 

--Total population vs Vaccination
--Showing the Precntage that got vaccination

Select CD.continent, CD.location, CD.date, Cd.population, CV.new_vaccinations
from Portfolio_Project..CovidDeaths CD
Join Portfolio_Project..CovidVaccinations CV
	On CD.location = CV.location
	AND CD.date = CV.date
where CD.continent is not null
order by 2,3

-- looking at the new Vaccination pet day >> rolling count

Select CD.continent, CD.location, CD.date, Cd.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations))over(partition by CD.Location order by CD.location, CD.date) as TotalVacciRollingCount
from Portfolio_Project..CovidDeaths CD
Join Portfolio_Project..CovidVaccinations CV
	On CD.location = CV.location
	AND CD.date = CV.date
where CD.continent is not null
order by 2,3

-- Total Vaccinated percentage by population using CTE

With PopuVsVac(continent, location, date, population,new_vaccination, TotalVacciRollingCount)
as 
(Select CD.continent, CD.location, CD.date, Cd.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations))over(partition by CD.Location order by CD.location, CD.date) as TotalVacciRollingCount
from Portfolio_Project..CovidDeaths CD
Join Portfolio_Project..CovidVaccinations CV
	On CD.location = CV.location
	AND CD.date = CV.date
where CD.continent is not null
)
select *, (TotalVacciRollingCount/population)*100 
from PopuVsVac

-- Total Vaccinated percentage by population using TEMP TABLE

Drop table if  exists #PrecentPopulationVaccinated
CREATE TABLE #PrecentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacciRollingCount numeric
)
Insert into #PrecentPopulationVaccinated
Select CD.continent, CD.location, CD.date, Cd.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations))over(partition by CD.Location order by CD.location, CD.date) as TotalVacciRollingCount
from Portfolio_Project..CovidDeaths CD
Join Portfolio_Project..CovidVaccinations CV
	On CD.location = CV.location
	AND CD.date = CV.date
--where CD.continent is not null
--order by 2,3

select *
from #PrecentPopulationVaccinated

--Creating a View to store data for visualation 

Create View PrecentPopulationVaccinated as 
Select CD.continent, CD.location, CD.date, Cd.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations))over(partition by CD.Location order by CD.location, CD.date) as TotalVacciRollingCount
from Portfolio_Project..CovidDeaths CD
Join Portfolio_Project..CovidVaccinations CV
	On CD.location = CV.location
	AND CD.date = CV.date
where CD.continent is not null
--order by 2,3

select * 
from PrecentPopulationVaccinated