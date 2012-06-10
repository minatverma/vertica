###
### Returns month name
###
monthName<- function(x)
{
        month_name <- months(as.Date(paste("2000-",x,"-01",sep='')))
        month_name
}

monthNameFactory <- function()
{
        list(name=monthName, udxtype=c("scalar"), intype=c("int"), outtype=c("varchar"))
}

