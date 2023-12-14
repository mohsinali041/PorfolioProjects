select *
from PortfolioProject.dbo.['covid-deaths$']
order by 3,4

select location, date, total_cases, new_cases, 
total_deaths, population
from PortfolioProject.dbo.['covid-deaths$']
order by 1,2

--looking at total deaths vs total cases

select location, date, total_cases, total_deaths,
(cast(total_deaths as float)/cast(total_cases as float)) * 100 as Death_percentage
from PortfolioProject.dbo.['covid-deaths$']
where location like '%state%'
order by 1,2

--looking at total cases vs population
--shows what %age of population got covid

select location, date, total_cases, population,
(cast(total_cases as float)/cast(population as float)) * 100 as Death_percentage
from PortfolioProject.dbo.['covid-deaths$']
where location like '%state%'
order by 1,2

-- looking at the countries with highest infection rate

select location, population, 
max(total_cases) as HighestInfectionCount,
max((cast(total_cases as float)/cast(population as float))) 
* 100 as PercentPopulationInfected
from PortfolioProject.dbo.['covid-deaths$']
where location like '%state%'
group by location, population
order by PercentPopulationInfected desc

-- looking at the countries with highest death rate

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.['covid-deaths$']
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.['covid-deaths$']
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from PortfolioProject.dbo.['covid-deaths$']
where continent is not null
group by date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION.

select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by dea.location, dea.date) 
from PortfolioProject.dbo.['covid-deaths$'] as dea
join PortfolioProject.dbo.['covid-vaccinations$'] as vac
on dea.date=vac.date
and dea.location=vac.location
where vac.new_vaccinations is not null
order by 1,2,3

----USING CTE ( COMMON TABLE EXPRESSION )

with popvsvac(location, continent, date, new_vaccination, population, RollingPeopleVaccinated)
as
(select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject.dbo.['covid-deaths$'] as dea
join PortfolioProject.dbo.['covid-vaccinations$'] as vac
on dea.date=vac.date
and dea.location=vac.location
where vac.new_vaccinations is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/population) *100
from popvsvac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Location Nvarchar(250),
Continent nvarchar(250),
Date datetime,
New_vaccinations numeric,
Population numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject.dbo.['covid-deaths$'] as dea
join PortfolioProject.dbo.['covid-vaccinations$'] as vac
on dea.date=vac.date
and dea.location=vac.location
--where vac.new_vaccinations is not null

select *, (RollingPeopleVaccinated/nullif(Population,0)) * 100
from #PercentPopulationVaccinated

select population, count(Population)
from #PercentPopulationVaccinated
where Population is not null
group by Population
having count(Population) is null

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZTION

go
CREATE VIEW PercentPopulationVaccinated2
as
select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject.dbo.['covid-deaths$'] as dea
join PortfolioProject.dbo.['covid-vaccinations$'] as vac
on dea.date=vac.date
and dea.location=vac.location
go

select *
from PercentPopulationVaccinated2
