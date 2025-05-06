#include "../includes/libft.h"

int	ft_strcasecmp(const char *s1, const char *s2)
{
	size_t	i;

	i = 0;
	while ((s1[i] || s2[i]))
	{
	    int s1_lower = ft_tolower(s1[i]);
	    int s2_lower = ft_tolower(s2[i]);
		if (s1_lower != s2_lower)
			return (s1_lower - s2_lower);
		i++;
	}
	return (0);
}
