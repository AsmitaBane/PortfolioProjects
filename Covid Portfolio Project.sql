select * from PortfolioProject..CovidVaccine$ order by 3,4;
select * from PortfolioProject..CovidDeaths$ 
where continent is not null order by 3,4;

--select data we are going to use

select location,date,new_cases,
total_cases,total_deaths,population 
from PortfolioProject..CovidDeaths$ order by 1,2;

--Looking at total cases vs death
select location,date,
total_cases,total_deaths,(total_deaths/total_cases) *100 deathpercentage
from PortfolioProject..CovidDeaths$ 
where location like '%India%'
order by 1,2;


--Looking at total cases vs population
select location,date,
total_cases,population,(total_cases/population) *100 affectedpercentage
from PortfolioProject..CovidDeaths$ 
where location like '%India%'
order by 1,2;

--Looking at countries with highest infection rate compare to population
select location,population,max(total_cases) Highestinfectioncount,max((total_cases/population)) *100 Inffectedpercentage
from PortfolioProject..CovidDeaths$ 
group by location,population
order by Inffectedpercentage desc;

--Looking at countries with highest death rate compare to population

select location,population,max(cast(total_deaths as int)) Totaldeathcount,max((total_deaths/population)) *100 Deathpercentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by location,population
order by Totaldeathcount desc;

--Continet
--Showing the continents with highest death count
select continent,max(cast(total_deaths as int)) Totaldeathcount
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by continent
order by Totaldeathcount desc;


--GLOBAL NUMBERS
select date, sum(new_cases) totalcases,sum(cast(new_deaths as int)) totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) *100 deathpercentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by date
order by 1,2;

--Looking at total population vs vaccine
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) Rollingvaccine
from PortfolioProject..CovidDeaths$  d
join PortfolioProject..CovidVaccine$  v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 order by 2,3

 --use CTE
 with PopvsVac(continent,location,date,population,new_vaccinations,Rollingvaccine)
 as
 (
 select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) Rollingvaccine
from PortfolioProject..CovidDeaths$  d
join PortfolioProject..CovidVaccine$  v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 --order by 2,3
 )
 select *,(Rollingvaccine/population)*100 rollingpercent from PopvsVac

 --without date

 select d.continent,d.location,d.population,max(v.total_vaccinations) Totalvaccination
from PortfolioProject..CovidDeaths$  d
join PortfolioProject..CovidVaccine$  v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 group by d.continent,d.location,d.population
 
 --TEMP TABLE
 Drop table if exists PerPopulationVaccinated
 create table PerPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date date,
 population numeric,
 new_vaccinations numeric,
 Rollingvaccine numeric
 )
 --Create view for visualtizations
create view PerPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) Rollingvaccine
from PortfolioProject..CovidDeaths$  d
join PortfolioProject..CovidVaccine$  v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 --order by 2,3

 select * from PerPopulationVaccinated