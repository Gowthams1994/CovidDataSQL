select * from CovidDeaths where continent is null order by 3,4
select * from CovidVaccinations order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contact covid in your country
 select Location,date,total_cases,total_deaths,cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
 from CovidDeaths
 where location like '%India%'
order by 1,2

--Looking at Total cases vs Total Population
--Shows what percentage of population got Covid
 select Location,date,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as CasePercentage
 from CovidDeaths
 where location like '%India%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

 select Location,population,max(total_cases)as HighestInfectedCount,max(cast(total_cases as float)/cast(population as float))*100 as CasePercentage
 from CovidDeaths
 --where location like '%India%'
 group by Location,population
order by CasePercentage desc

--showing countries with highest death count per population

 select Location,Max(cast(total_deaths as int))as TotalDeathCount
 from CovidDeaths
 where continent is not null
 group by Location
order by TotalDeathCount desc

--showing Continents with highest death count per population
 select continent,Max(cast(total_deaths as int))as TotalDeathCount
 from CovidDeaths
 where continent is not null
 group by continent
order by TotalDeathCount desc

--Global Numbers
 select SUM(new_cases) as NewTotalcases,sum(cast(new_deaths as int))as NewTotalDeaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as CasePercentage
 from CovidDeaths
 where continent is not null
 --group by Date
 having sum(cast(new_deaths as int))>0
order by 1,2 desc


--Looking at Total Population Vs Vaccinations

select a.continent,a.location,a.date,a.population, b.new_vaccinations,
sum(cast(new_vaccinations as float)) over(partition by a.Location order by a.location,a.date) as RollingPeopleVaccinated
from 
CovidDeaths a join CovidVaccinations b on a.location=b.location
and a.date=b.date
where a.continent is not null
order by 2,3

--with CTE
with CTE(Continent,Location,date,Population,New_vaccinations,RollingPeopleVaccinated)
 as(
select a.continent,a.location,a.date,a.population, b.new_vaccinations,
sum(cast(new_vaccinations as float)) over(partition by a.Location order by a.location,a.date) as RollingPeopleVaccinated
from 
CovidDeaths a join CovidVaccinations b on a.location=b.location
and a.date=b.date
where a.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100 from CTE

--Temp Table

IF OBJECT_ID(N'tempdb..#PercentpopulationVaccinated') IS NOT NULL
DROP TABLE #PercentpopulationVaccinated

create table #PercentpopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

insert into #PercentpopulationVaccinated
select a.continent,a.location,a.date,a.population, b.new_vaccinations,
sum(cast(new_vaccinations as float)) over(partition by a.Location order by a.location,a.date) as RollingPeopleVaccinated
from 
CovidDeaths a join CovidVaccinations b on a.location=b.location
and a.date=b.date
where a.continent is not null

select * from #PercentpopulationVaccinated

--View
create view PercentpopulationVaccinated as
select a.continent,a.location,a.date,a.population, b.new_vaccinations,
sum(cast(new_vaccinations as float)) over(partition by a.Location order by a.location,a.date) as RollingPeopleVaccinated
from 
CovidDeaths a join CovidVaccinations b on a.location=b.location
and a.date=b.date
where a.continent is not null


select * from PercentpopulationVaccinated